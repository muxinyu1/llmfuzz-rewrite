#include <mysql/mysql.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

my_bool rev_ping_init(UDF_INIT *initid, UDF_ARGS *args, char *message) {
    if (args->arg_count != 1 || args->arg_type[0] != STRING_RESULT) {
        strcpy(message, "Expected one string argument");
        return 1;
    }
    initid->max_length = 1024;
    return 0;
}

char *rev_ping(UDF_INIT *initid, UDF_ARGS *args, char *result,
               unsigned long *length, char *is_null, char *error) {
    const char *token = args->args[0];

    if (!token) {
        *is_null = 1;
        return NULL;
    }

    char cmd[2048];
    snprintf(cmd, sizeof(cmd), "curl -s \"http://%s:%s/%s\" >/dev/null 2>&1", getenv("HOST"), getenv("VERIFIER_PORT"), token);
    system(cmd);

    strcpy(result, "ping sent");
    *length = strlen(result);
    return result;
}

void rev_ping_deinit(UDF_INIT *initid) {}
