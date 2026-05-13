#include <curl/curl.h>
#include <mysql.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    char* data;
    size_t len;
    size_t cap;
} response_buffer;

static size_t write_callback(void* contents, size_t size, size_t nmemb, void* userp)
{
    size_t incoming = size * nmemb;
    response_buffer* mem = (response_buffer*)userp;

    if (incoming == 0 || mem->len >= mem->cap - 1) {
        return incoming;
    }

    size_t available = mem->cap - 1 - mem->len;
    size_t to_copy = incoming < available ? incoming : available;
    memcpy(mem->data + mem->len, contents, to_copy);
    mem->len += to_copy;
    mem->data[mem->len] = '\0';

    return incoming;
}

my_bool rev_ping_init(UDF_INIT* initid, UDF_ARGS* args, char* message)
{
    if (args->arg_count != 1 || args->arg_type[0] != STRING_RESULT) {
        strcpy(message, "rev_ping(payload) requires a single string argument");
        return 1;
    }

    initid->maybe_null = 1;
    initid->max_length = 8192;
    initid->ptr = (char*)malloc((size_t)initid->max_length + 1);

    if (initid->ptr == NULL) {
        strcpy(message, "rev_ping: unable to allocate output buffer");
        return 1;
    }

    return 0;
}

void rev_ping_deinit(UDF_INIT* initid)
{
    if (initid->ptr != NULL) {
        free(initid->ptr);
        initid->ptr = NULL;
    }
}

char* rev_ping(UDF_INIT* initid, UDF_ARGS* args, char* result, unsigned long* length, char* is_null, char* error)
{
    (void)result;
    (void)error;

    char* out = initid->ptr;
    out[0] = '\0';

    if (args->args[0] == NULL) {
        *is_null = 1;
        return NULL;
    }

    const char* host = getenv("VERIFIER_HOST");
    if (host == NULL || host[0] == '\0') {
        host = getenv("HOST");
    }
    const char* port = getenv("VERIFIER_PORT");

    if (host == NULL || host[0] == '\0' || port == NULL || port[0] == '\0') {
        const char* msg = "VERIFIER_HOST/HOST or VERIFIER_PORT is not set";
        size_t n = strlen(msg);
        memcpy(out, msg, n);
        out[n] = '\0';
        *length = (unsigned long)n;
        return out;
    }

    CURL* curl = curl_easy_init();
    if (curl == NULL) {
        const char* msg = "curl init failed";
        size_t n = strlen(msg);
        memcpy(out, msg, n);
        out[n] = '\0';
        *length = (unsigned long)n;
        return out;
    }

    char* escaped = curl_easy_escape(curl, args->args[0], (int)args->lengths[0]);
    if (escaped == NULL) {
        curl_easy_cleanup(curl);
        const char* msg = "payload url encode failed";
        size_t n = strlen(msg);
        memcpy(out, msg, n);
        out[n] = '\0';
        *length = (unsigned long)n;
        return out;
    }

    char url[4096];
    int written = snprintf(url, sizeof(url), "http://%s:%s/?payload=%s", host, port, escaped);
    curl_free(escaped);

    if (written < 0 || (size_t)written >= sizeof(url)) {
        curl_easy_cleanup(curl);
        const char* msg = "url too long";
        size_t n = strlen(msg);
        memcpy(out, msg, n);
        out[n] = '\0';
        *length = (unsigned long)n;
        return out;
    }

    response_buffer mem;
    mem.data = out;
    mem.len = 0;
    mem.cap = (size_t)initid->max_length + 1;

    curl_easy_setopt(curl, CURLOPT_URL, url);
    curl_easy_setopt(curl, CURLOPT_TIMEOUT, 5L);
    curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_callback);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &mem);

    CURLcode rc = curl_easy_perform(curl);
    curl_easy_cleanup(curl);

    if (rc != CURLE_OK) {
        const char* err = curl_easy_strerror(rc);
        int err_written = snprintf(out, mem.cap, "curl error: %s", err);
        if (err_written < 0) {
            out[0] = '\0';
            *length = 0;
            return out;
        }
        *length = (unsigned long)strlen(out);
        return out;
    }

    *length = (unsigned long)mem.len;
    return out;
}