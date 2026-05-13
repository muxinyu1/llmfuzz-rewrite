<?php
/* Smarty version 3.1.32, created on 2026-05-10 17:42:09
  from '/var/www/html/themes/default/main.tpl' */

/* @var Smarty_Internal_Template $_smarty_tpl */
if ($_smarty_tpl->_decodeProperties($_smarty_tpl, array (
  'version' => '3.1.32',
  'unifunc' => 'content_6a00c3716fafa5_76383082',
  'has_nocache_code' => false,
  'file_dependency' => 
  array (
    '2661a0239ad432835cd569e362f4e04ee2ee2976' => 
    array (
      0 => '/var/www/html/themes/default/main.tpl',
      1 => 1778433611,
      2 => 'file',
    ),
  ),
  'includes' => 
  array (
  ),
),false)) {
function content_6a00c3716fafa5_76383082 (Smarty_Internal_Template $_smarty_tpl) {
$_smarty_tpl->_checkPlugins(array(0=>array('file'=>'/var/www/html/modules/smarty/plugins/modifier.replace.php','function'=>'smarty_modifier_replace',),));
$_smarty_tpl->smarty->ext->configLoad->_loadConfigFile($_smarty_tpl, $_smarty_tpl->tpl_vars['language_file']->value, "general", 0);
if ($_smarty_tpl->tpl_vars['subnav_location']->value && $_smarty_tpl->tpl_vars['subnav_location_var']->value) {
$_smarty_tpl->_assignInScope('subnav_location', smarty_modifier_replace($_smarty_tpl->smarty->ext->configload->_getConfigVariable($_smarty_tpl, $_smarty_tpl->tpl_vars['subnav_location']->value),"[var]",$_smarty_tpl->tpl_vars['subnav_location_var']->value));
} elseif ($_smarty_tpl->tpl_vars['subnav_location']->value) {
$_smarty_tpl->_assignInScope('subnav_location', $_smarty_tpl->smarty->ext->configload->_getConfigVariable($_smarty_tpl, $_smarty_tpl->tpl_vars['subnav_location']->value));
}?><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'language');?>
" dir="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'dir');?>
">
<head>
<meta http-equiv="content-type" content="text/html; charset=<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'charset');?>
" />
<title><?php if ($_smarty_tpl->tpl_vars['page_title']->value) {
echo $_smarty_tpl->tpl_vars['page_title']->value;?>
 - <?php } elseif ($_smarty_tpl->tpl_vars['subnav_location']->value) {
echo $_smarty_tpl->tpl_vars['subnav_location']->value;?>
 - <?php }
echo htmlspecialchars($_smarty_tpl->tpl_vars['settings']->value['forum_name'], ENT_QUOTES, 'UTF-8', true);?>
</title>
<meta name="description" content="<?php echo htmlspecialchars($_smarty_tpl->tpl_vars['settings']->value['forum_description'], ENT_QUOTES, 'UTF-8', true);?>
" />
<?php if ($_smarty_tpl->tpl_vars['keywords']->value) {?><meta name="keywords" content="<?php echo $_smarty_tpl->tpl_vars['keywords']->value;?>
" /><?php }
if ($_smarty_tpl->tpl_vars['mode']->value == 'posting') {?>
<meta name="robots" content="noindex" />
<?php }?>
<meta name="referrer" content="origin" />
<meta name="referrer" content="same-origin" />
<meta name="generator" content="my little forum <?php echo $_smarty_tpl->tpl_vars['settings']->value['version'];?>
" />
<link rel="stylesheet" type="text/css" href="<?php echo $_smarty_tpl->tpl_vars['FORUM_ADDRESS']->value;?>
/<?php echo $_smarty_tpl->tpl_vars['THEMES_DIR']->value;?>
/<?php echo $_smarty_tpl->tpl_vars['theme']->value;?>
/style.min.css" media="all" />
<?php if ($_smarty_tpl->tpl_vars['settings']->value['rss_feed'] == 1) {?><link rel="alternate" type="application/rss+xml" title="RSS" href="index.php?mode=rss" /><?php }
if (!$_smarty_tpl->tpl_vars['top']->value) {?>
<link rel="top" href="./" />
<?php }
if ($_smarty_tpl->tpl_vars['link_rel_first']->value) {?>
<link rel="first" href="<?php echo $_smarty_tpl->tpl_vars['link_rel_first']->value;?>
" />
<?php }
if ($_smarty_tpl->tpl_vars['link_rel_prev']->value) {?>
<link rel="prev" href="<?php echo $_smarty_tpl->tpl_vars['link_rel_prev']->value;?>
" />
<?php }
if ($_smarty_tpl->tpl_vars['link_rel_last']->value) {?>
<link rel="last" href="<?php echo $_smarty_tpl->tpl_vars['link_rel_last']->value;?>
" />
<?php }?>
<link rel="search" href="index.php?mode=search" />
<link rel="shortcut icon" href="<?php echo $_smarty_tpl->tpl_vars['FORUM_ADDRESS']->value;?>
/<?php echo $_smarty_tpl->tpl_vars['THEMES_DIR']->value;?>
/<?php echo $_smarty_tpl->tpl_vars['theme']->value;?>
/images/favicon.ico" />
<?php if ($_smarty_tpl->tpl_vars['mode']->value == 'entry') {?><link rel="canonical" href="<?php echo $_smarty_tpl->tpl_vars['settings']->value['forum_address'];?>
index.php?mode=thread&amp;id=<?php echo $_smarty_tpl->tpl_vars['tid']->value;?>
" /><?php }
echo '<script'; ?>
 src="<?php echo $_smarty_tpl->tpl_vars['FORUM_ADDRESS']->value;?>
/index.php?mode=js_defaults&amp;t=<?php echo $_smarty_tpl->tpl_vars['settings']->value['last_changes'];
if ($_smarty_tpl->tpl_vars['user']->value) {?>&amp;user_type=<?php if ($_smarty_tpl->tpl_vars['mod']->value) {?>1<?php } elseif ($_smarty_tpl->tpl_vars['admin']->value) {?>2<?php } else { ?>0<?php }
}?>" type="text/javascript" charset="utf-8"><?php echo '</script'; ?>
>
<?php echo '<script'; ?>
 src="<?php echo $_smarty_tpl->tpl_vars['FORUM_ADDRESS']->value;?>
/js/main.min.js" type="text/javascript" charset="utf-8"><?php echo '</script'; ?>
>
<?php if ($_smarty_tpl->tpl_vars['mode']->value == 'posting') {
echo '<script'; ?>
 src="<?php echo $_smarty_tpl->tpl_vars['FORUM_ADDRESS']->value;?>
/js/posting.min.js" type="text/javascript" charset="utf-8"><?php echo '</script'; ?>
>
<?php }
if ($_smarty_tpl->tpl_vars['mode']->value == 'admin') {
echo '<script'; ?>
 src="<?php echo $_smarty_tpl->tpl_vars['FORUM_ADDRESS']->value;?>
/js/admin.min.js" type="text/javascript" charset="utf-8"><?php echo '</script'; ?>
>
<?php }
if ($_smarty_tpl->tpl_vars['settings']->value['bbcode_latex'] && $_smarty_tpl->tpl_vars['settings']->value['bbcode_latex_uri']) {
echo '<script'; ?>
 type="text/javascript" async src="<?php echo $_smarty_tpl->tpl_vars['settings']->value['bbcode_latex_uri'];?>
"><?php echo '</script'; ?>
>
<?php echo '<script'; ?>
 type="text/x-mathjax-config">/*<![CDATA[*/MathJax.Hub.Config({
    tex2jax: {
        inlineMath: [ ["$","$"], ["\\(","\\)"] ],
        displayMath: [ ["$$","$$"], ["\\[","\\]"] ],
		ignoreClass: "tex2jax_ignore",
		processClass: "tex2jax_process",
        processEscapes: true
    },

    TeX: {
        equationNumbers: { autoNumber: "AMS" }
    }
});
/*!]]>*/<?php echo '</script'; ?>
>
<?php }?>
</head>

<body class="tex2jax_ignore">
<!--[if IE]><div id="ie"><![endif]-->

<div id="top">

<div id="logo">
<?php if ($_smarty_tpl->tpl_vars['settings']->value['home_linkname']) {?><p class="home"><a href="<?php echo $_smarty_tpl->tpl_vars['settings']->value['home_linkaddress'];?>
"><?php echo $_smarty_tpl->tpl_vars['settings']->value['home_linkname'];?>
</a></p><?php }?>
<h1><a href="./" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'forum_index_link_title');?>
"><?php echo htmlspecialchars($_smarty_tpl->tpl_vars['settings']->value['forum_name'], ENT_QUOTES, 'UTF-8', true);?>
</a></h1>
</div>

<div id="nav">
<ul id="usermenu">
<?php if ($_smarty_tpl->tpl_vars['user']->value) {?><li><a href="index.php?mode=user&amp;action=edit_profile" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'profile_link_title');?>
"><strong><?php echo $_smarty_tpl->tpl_vars['user']->value;?>
</strong></a></li><li><a href="index.php?mode=user&amp;action=show_posts&amp;id=<?php echo $_smarty_tpl->tpl_vars['user_id']->value;?>
"><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'show_all_postings_link');?>
</a></li><li><a href="index.php?mode=bookmarks"><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'show_bookmarks_link');?>
</a></li><?php if (($_smarty_tpl->tpl_vars['admin']->value || $_smarty_tpl->tpl_vars['mod']->value) || ($_smarty_tpl->tpl_vars['settings']->value['user_area_access'] > 0)) {?><li><a href="index.php?mode=user" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'user_area_link_title');?>
"><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'user_area_link');?>
</a></li><?php }
if ($_smarty_tpl->tpl_vars['admin']->value) {?><li><a href="index.php?mode=admin" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'admin_area_link_title');?>
"><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'admin_area_link');?>
</a></li><?php }?><li><a href="index.php?mode=login" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'log_out_link_title');?>
"><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'log_out_link');?>
</a></li><?php } else { ?><li><a href="index.php?mode=login" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'log_in_link_title');?>
"><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'log_in_link');?>
</a></li><?php if ($_smarty_tpl->tpl_vars['settings']->value['register_mode'] != 2) {?><li><a href="index.php?mode=register" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'register_link_title');?>
"><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'register_link');?>
</a></li><?php }
if ($_smarty_tpl->tpl_vars['settings']->value['user_area_access'] == 2) {?><li><a href="index.php?mode=user" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'user_area_link_title');?>
"><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'user_area_link');?>
</a></li><?php }
}
if ($_smarty_tpl->tpl_vars['menu']->value) {
$_from = $_smarty_tpl->smarty->ext->_foreach->init($_smarty_tpl, $_smarty_tpl->tpl_vars['menu']->value, 'item');
if ($_from !== null) {
foreach ($_from as $_smarty_tpl->tpl_vars['item']->value) {
?><li><a href="index.php?mode=page&amp;id=<?php echo $_smarty_tpl->tpl_vars['item']->value['id'];?>
"><?php echo $_smarty_tpl->tpl_vars['item']->value['linkname'];?>
</a></li><?php
}
}
$_smarty_tpl->smarty->ext->_foreach->restore($_smarty_tpl, 1);
}?>
</ul>
<form id="topsearch" action="index.php" method="get" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'search_title');?>
" accept-charset="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'charset');?>
"><div><input type="hidden" name="mode" value="search" /><label for="search-input"><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'search_marking');?>
</label>&nbsp;<input id="search-input" type="text" name="search" value="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'search_default_value');?>
" /><!--&nbsp;<input type="image" src="templates/<?php echo $_smarty_tpl->tpl_vars['settings']->value['template'];?>
/images/submit.png" alt="[&raquo;]" />--></div></form></div>
</div>

<div id="subnav">
<div id="subnav-1"><?php $_smarty_tpl->_subTemplateRender(((string)$_smarty_tpl->tpl_vars['theme']->value)."/subtemplates/subnavigation_1.inc.tpl", $_smarty_tpl->cache_id, $_smarty_tpl->compile_id, 0, $_smarty_tpl->cache_lifetime, array(), 0, true);
?></div>
<div id="subnav-2"><?php $_smarty_tpl->_subTemplateRender(((string)$_smarty_tpl->tpl_vars['theme']->value)."/subtemplates/subnavigation_2.inc.tpl", $_smarty_tpl->cache_id, $_smarty_tpl->compile_id, 0, $_smarty_tpl->cache_lifetime, array(), 0, true);
?></div>
</div>

<div id="content">
<?php if ($_smarty_tpl->tpl_vars['subtemplate']->value) {
$_smarty_tpl->_subTemplateRender(((string)$_smarty_tpl->tpl_vars['theme']->value)."/subtemplates/".((string)$_smarty_tpl->tpl_vars['subtemplate']->value), $_smarty_tpl->cache_id, $_smarty_tpl->compile_id, 0, $_smarty_tpl->cache_lifetime, array(), 0, true);
} else {
echo (($tmp = @$_smarty_tpl->tpl_vars['content']->value)===null||$tmp==='' ? '' : $tmp);?>

<?php }?>
</div>

<div id="footer">
<div id="footer-1"><?php if ($_smarty_tpl->tpl_vars['total_users_online']->value) {
echo smarty_modifier_replace(smarty_modifier_replace(smarty_modifier_replace(smarty_modifier_replace(smarty_modifier_replace(smarty_modifier_replace($_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'counter_users_online'),"[total_postings]",$_smarty_tpl->tpl_vars['total_postings']->value),"[total_threads]",$_smarty_tpl->tpl_vars['total_threads']->value),"[registered_users]",$_smarty_tpl->tpl_vars['registered_users']->value),"[total_users_online]",$_smarty_tpl->tpl_vars['total_users_online']->value),"[registered_users_online]",$_smarty_tpl->tpl_vars['registered_users_online']->value),"[unregistered_users_online]",$_smarty_tpl->tpl_vars['unregistered_users_online']->value);
} else {
echo smarty_modifier_replace(smarty_modifier_replace(smarty_modifier_replace($_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'counter'),"[total_postings]",$_smarty_tpl->tpl_vars['total_postings']->value),"[total_threads]",$_smarty_tpl->tpl_vars['total_threads']->value),"[registered_users]",$_smarty_tpl->tpl_vars['registered_users']->value);
}?><br />
<?php if ($_smarty_tpl->tpl_vars['forum_time_zone']->value) {
echo smarty_modifier_replace(smarty_modifier_replace($_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'forum_time_with_time_zone'),'[time]',$_smarty_tpl->tpl_vars['forum_time']->value),'[time_zone]',$_smarty_tpl->tpl_vars['forum_time_zone']->value);
} else {
echo smarty_modifier_replace($_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'forum_time'),'[time]',$_smarty_tpl->tpl_vars['forum_time']->value);
}?></div>
<div id="footer-2">
<ul id="footermenu">
<?php if ($_smarty_tpl->tpl_vars['settings']->value['rss_feed'] == 1) {?><li><a class="rss" href="index.php?mode=rss" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'rss_feed_postings_title');?>
"><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'rss_feed_postings');?>
</a> &nbsp;<a class="rss" href="index.php?mode=rss&amp;items=thread_starts" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'rss_feed_new_threads_title');?>
"><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'rss_feed_new_threads');?>
</a></li><?php }?><li><a href="index.php?mode=contact" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'contact_linktitle');?>
" rel="nofollow"><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'contact_link');?>
</a></li>
</ul></div>
</div>

<div id="pbmlf"><a href="https://mylittleforum.net/">powered by my little forum</a></div>

<!--[if IE]></div><![endif]-->

</body>
</html>
<?php }
}
