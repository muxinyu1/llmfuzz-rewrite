<?php
/* Smarty version 3.1.32, created on 2026-05-10 17:42:49
  from '/var/www/html/themes/default/subtemplates/index.inc.tpl' */

/* @var Smarty_Internal_Template $_smarty_tpl */
if ($_smarty_tpl->_decodeProperties($_smarty_tpl, array (
  'version' => '3.1.32',
  'unifunc' => 'content_6a00c39943cc08_29367747',
  'has_nocache_code' => false,
  'file_dependency' => 
  array (
    '97a6224a274495b7b6c4a60686148d520596228e' => 
    array (
      0 => '/var/www/html/themes/default/subtemplates/index.inc.tpl',
      1 => 1778433611,
      2 => 'file',
    ),
  ),
  'includes' => 
  array (
  ),
),false)) {
function content_6a00c39943cc08_29367747 (Smarty_Internal_Template $_smarty_tpl) {
$_smarty_tpl->smarty->ext->_tplFunction->registerTplFunctions($_smarty_tpl, array (
  'tree' => 
  array (
    'compiled_filepath' => '/var/www/html/templates_c/97a6224a274495b7b6c4a60686148d520596228e_0.file.index.inc.tpl.php',
    'uid' => '97a6224a274495b7b6c4a60686148d520596228e',
    'call_name' => 'smarty_template_function_tree_10743639866a00c399414370_31842828',
  ),
));
$_smarty_tpl->_checkPlugins(array(0=>array('file'=>'/var/www/html/modules/smarty/plugins/modifier.replace.php','function'=>'smarty_modifier_replace',),));
if ($_smarty_tpl->tpl_vars['tag_cloud']->value || $_smarty_tpl->tpl_vars['latest_postings']->value || $_smarty_tpl->tpl_vars['admin']->value || $_smarty_tpl->tpl_vars['mod']->value) {?>
<div id="sidebar"<?php if ($_smarty_tpl->tpl_vars['usersettings']->value['sidebar'] == 0) {?> class="js-display-fold"<?php }?>>
<a href="index.php?toggle_sidebar=true"><img id="sidebartoggle" class="<?php if ($_smarty_tpl->tpl_vars['usersettings']->value['sidebar'] == 0) {?>show-sidebar<?php } else { ?>hide-sidebar<?php }?>" src="<?php echo $_smarty_tpl->tpl_vars['THEMES_DIR']->value;?>
/<?php echo $_smarty_tpl->tpl_vars['theme']->value;?>
/images/plain.png" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'toggle_sidebar');?>
" alt="[+/-]" width="9" height="9" /></a>
<h3 class="sidebar"><a href="index.php?toggle_sidebar=true" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'toggle_sidebar');?>
"><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'sidebar');?>
</a></h3>
<div id="sidebarcontent">
<?php if ($_smarty_tpl->tpl_vars['latest_postings']->value) {?>
<div id="latest-postings">
<h3><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'latest_postings_hl');?>
</h3>
<ul id="latest-postings-container">
<?php
$_from = $_smarty_tpl->smarty->ext->_foreach->init($_smarty_tpl, $_smarty_tpl->tpl_vars['latest_postings']->value, 'posting');
if ($_from !== null) {
foreach ($_from as $_smarty_tpl->tpl_vars['posting']->value) {
?><li><a href="index.php?id=<?php echo $_smarty_tpl->tpl_vars['posting']->value['id'];?>
" title="<?php echo $_smarty_tpl->tpl_vars['posting']->value['name'];?>
, <?php echo $_smarty_tpl->tpl_vars['posting']->value['formated_time'];
if ($_smarty_tpl->tpl_vars['posting']->value['category_name']) {?> (<?php echo $_smarty_tpl->tpl_vars['posting']->value['category_name'];?>
)<?php }?>"<?php if ($_smarty_tpl->tpl_vars['posting']->value['is_read']) {?> class="read"<?php }?>><span class="entry-title"><?php if ($_smarty_tpl->tpl_vars['posting']->value['pid'] == 0) {?><strong><?php echo $_smarty_tpl->tpl_vars['posting']->value['subject'];?>
</strong><?php } else {
echo $_smarty_tpl->tpl_vars['posting']->value['subject'];
}?></span><br />
<span class="entry-date"><?php if ($_smarty_tpl->tpl_vars['posting']->value['ago']['days'] > 1) {
echo smarty_modifier_replace($_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'posting_several_days_ago'),"[days]",$_smarty_tpl->tpl_vars['posting']->value['ago']['days_rounded']);
} else {
if ($_smarty_tpl->tpl_vars['posting']->value['ago']['days'] == 0 && $_smarty_tpl->tpl_vars['posting']->value['ago']['hours'] == 0) {
echo smarty_modifier_replace($_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'posting_minutes_ago'),"[minutes]",$_smarty_tpl->tpl_vars['posting']->value['ago']['minutes']);
} elseif ($_smarty_tpl->tpl_vars['posting']->value['ago']['days'] == 0 && $_smarty_tpl->tpl_vars['posting']->value['ago']['hours'] != 0) {
echo smarty_modifier_replace(smarty_modifier_replace($_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'posting_hours_ago'),"[hours]",$_smarty_tpl->tpl_vars['posting']->value['ago']['hours']),"[minutes]",$_smarty_tpl->tpl_vars['posting']->value['ago']['minutes']);
} else {
echo smarty_modifier_replace(smarty_modifier_replace($_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'posting_one_day_ago'),"[hours]",$_smarty_tpl->tpl_vars['posting']->value['ago']['hours']),"[minutes]",$_smarty_tpl->tpl_vars['posting']->value['ago']['minutes']);
}
}?></span></a></li><?php
}
}
$_smarty_tpl->smarty->ext->_foreach->restore($_smarty_tpl, 1);?>
</ul>
</div>
<?php }
if ($_smarty_tpl->tpl_vars['tag_cloud']->value) {?>
<div id="tagcloud">
<h3><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'tag_cloud_hl');?>
</h3>
<p id="tagcloud-container"><?php
$_from = $_smarty_tpl->smarty->ext->_foreach->init($_smarty_tpl, $_smarty_tpl->tpl_vars['tag_cloud']->value, 'tag');
if ($_from !== null) {
foreach ($_from as $_smarty_tpl->tpl_vars['tag']->value) {
$__section_strong_start_0_loop = (is_array(@$_loop=$_smarty_tpl->tpl_vars['tag']->value['frequency']) ? count($_loop) : max(0, (int) $_loop));
$__section_strong_start_0_start = min(0, $__section_strong_start_0_loop);
$__section_strong_start_0_total = min(($__section_strong_start_0_loop - $__section_strong_start_0_start), $__section_strong_start_0_loop);
$_smarty_tpl->tpl_vars['__smarty_section_strong_start'] = new Smarty_Variable(array());
if ($__section_strong_start_0_total !== 0) {
for ($__section_strong_start_0_iteration = 1, $_smarty_tpl->tpl_vars['__smarty_section_strong_start']->value['index'] = $__section_strong_start_0_start; $__section_strong_start_0_iteration <= $__section_strong_start_0_total; $__section_strong_start_0_iteration++, $_smarty_tpl->tpl_vars['__smarty_section_strong_start']->value['index']++){
?><strong><?php
}
}
?><a href="index.php?mode=search&amp;search=<?php echo $_smarty_tpl->tpl_vars['tag']->value['escaped'];?>
&amp;method=tags"><?php echo $_smarty_tpl->tpl_vars['tag']->value['tag'];?>
</a> <?php
$__section_strong_end_1_loop = (is_array(@$_loop=$_smarty_tpl->tpl_vars['tag']->value['frequency']) ? count($_loop) : max(0, (int) $_loop));
$__section_strong_end_1_start = min(0, $__section_strong_end_1_loop);
$__section_strong_end_1_total = min(($__section_strong_end_1_loop - $__section_strong_end_1_start), $__section_strong_end_1_loop);
$_smarty_tpl->tpl_vars['__smarty_section_strong_end'] = new Smarty_Variable(array());
if ($__section_strong_end_1_total !== 0) {
for ($__section_strong_end_1_iteration = 1, $_smarty_tpl->tpl_vars['__smarty_section_strong_end']->value['index'] = $__section_strong_end_1_start; $__section_strong_end_1_iteration <= $__section_strong_end_1_total; $__section_strong_end_1_iteration++, $_smarty_tpl->tpl_vars['__smarty_section_strong_end']->value['index']++){
?></strong><?php
}
}
}
}
$_smarty_tpl->smarty->ext->_foreach->restore($_smarty_tpl, 1);?></p>
</div>
<?php }
if ($_smarty_tpl->tpl_vars['admin']->value || $_smarty_tpl->tpl_vars['mod']->value) {?>
<div id="modmenu">
	<h3><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'options');?>
</h3>
	<ul id="mod-options">
		<?php if ($_smarty_tpl->tpl_vars['number_of_non_activated_users']->value) {?><li><a href="index.php?mode=user" class="non-activated-users"><?php echo smarty_modifier_replace($_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'non_activated_users_link'),'[counter]',$_smarty_tpl->tpl_vars['number_of_non_activated_users']->value);?>
</a></li><?php }?>
		<li><a href="index.php?mode=posting&amp;delete_marked=true" class="delete-marked"><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'delete_marked_link');?>
</a></li>
		<li><a href="index.php?mode=posting&amp;manage_postings=true" class="manage"><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'manage_postings_link');?>
</a></li>
		<?php if ($_smarty_tpl->tpl_vars['show_spam_link']->value) {?><li><a href="index.php?show_spam=true" class="report"><?php echo smarty_modifier_replace($_smarty_tpl->smarty->ext->configload->_getConfigVariable($_smarty_tpl, 'show_spam_link'),"[number]",$_smarty_tpl->tpl_vars['total_spam']->value);?>
</a></li><?php }?>
		<?php if ($_smarty_tpl->tpl_vars['hide_spam_link']->value) {?><li><a href="index.php?show_spam=true" class="report"><?php echo smarty_modifier_replace($_smarty_tpl->smarty->ext->configload->_getConfigVariable($_smarty_tpl, 'hide_spam_link'),"[number]",$_smarty_tpl->tpl_vars['total_spam']->value);?>
</a></li><?php }?>
		<?php if ($_smarty_tpl->tpl_vars['delete_spam_link']->value) {?><li><a href="index.php?mode=posting&amp;delete_spam=true" class="delete-spam"><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'delete_spam_link');?>
</a></li><?php }?>
	</ul>
</div>
<?php }?>
</div>
</div>
<?php }?>

<?php if ($_smarty_tpl->tpl_vars['threads']->value) {
$_from = $_smarty_tpl->smarty->ext->_foreach->init($_smarty_tpl, $_smarty_tpl->tpl_vars['threads']->value, 'thread');
if ($_from !== null) {
foreach ($_from as $_smarty_tpl->tpl_vars['thread']->value) {
?>
<ul id="thread-<?php echo $_smarty_tpl->tpl_vars['thread']->value;?>
" class="thread <?php if ($_smarty_tpl->tpl_vars['fold_threads']->value == 1) {?>folded<?php } else { ?>expanded<?php }?>">

<?php $_smarty_tpl->smarty->ext->_tplFunction->callTemplateFunction($_smarty_tpl, 'tree', array('element'=>$_smarty_tpl->tpl_vars['thread']->value), true);?>

</ul>
<?php
}
}
$_smarty_tpl->smarty->ext->_foreach->restore($_smarty_tpl, 1);
} else { ?>
<p><?php if ($_smarty_tpl->tpl_vars['category']->value != 0) {
echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'no_messages_in_category');
} else {
echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'no_messages');
}?></p>
<?php }?>

<?php if ($_smarty_tpl->tpl_vars['pagination']->value) {?>
<ul class="pagination pagination-index">
<?php if ($_smarty_tpl->tpl_vars['pagination']->value['previous']) {?><li><a href="index.php?mode=<?php echo $_smarty_tpl->tpl_vars['mode']->value;?>
&amp;page=<?php echo $_smarty_tpl->tpl_vars['pagination']->value['previous'];
if ($_smarty_tpl->tpl_vars['category']->value) {?>&amp;category=<?php echo $_smarty_tpl->tpl_vars['category']->value;
}?>" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'previous_page_link_title');?>
"><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'previous_page_link');?>
</a></li><?php }
$_from = $_smarty_tpl->smarty->ext->_foreach->init($_smarty_tpl, $_smarty_tpl->tpl_vars['pagination']->value['items'], 'item');
if ($_from !== null) {
foreach ($_from as $_smarty_tpl->tpl_vars['item']->value) {
if ($_smarty_tpl->tpl_vars['item']->value == 0) {?><li>&hellip;</li><?php } elseif ($_smarty_tpl->tpl_vars['item']->value == $_smarty_tpl->tpl_vars['pagination']->value['current']) {?><li><span class="current"><?php echo $_smarty_tpl->tpl_vars['item']->value;?>
</span></li><?php } else { ?><li><a href="index.php?mode=<?php echo $_smarty_tpl->tpl_vars['mode']->value;?>
&amp;page=<?php echo $_smarty_tpl->tpl_vars['item']->value;
if ($_smarty_tpl->tpl_vars['category']->value) {?>&amp;category=<?php echo $_smarty_tpl->tpl_vars['category']->value;
}?>"><?php echo $_smarty_tpl->tpl_vars['item']->value;?>
</a></li><?php }
}
}
$_smarty_tpl->smarty->ext->_foreach->restore($_smarty_tpl, 1);
if ($_smarty_tpl->tpl_vars['pagination']->value['next']) {?><li><a href="index.php?mode=<?php echo $_smarty_tpl->tpl_vars['mode']->value;?>
&amp;page=<?php echo $_smarty_tpl->tpl_vars['pagination']->value['next'];
if ($_smarty_tpl->tpl_vars['category']->value) {?>&amp;category=<?php echo $_smarty_tpl->tpl_vars['category']->value;
}?>" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'next_page_link_title');?>
"><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'next_page_link');?>
</a></li><?php }?>  
</ul>
<?php }
}
/* smarty_template_function_tree_10743639866a00c399414370_31842828 */
if (!function_exists('smarty_template_function_tree_10743639866a00c399414370_31842828')) {
function smarty_template_function_tree_10743639866a00c399414370_31842828(Smarty_Internal_Template $_smarty_tpl,$params) {
$params = array_merge(array('level'=>0), $params);
foreach ($params as $key => $value) {
$_smarty_tpl->tpl_vars[$key] = new Smarty_Variable($value, $_smarty_tpl->isRenderingCache);
}
$_smarty_tpl->_checkPlugins(array(0=>array('file'=>'/var/www/html/modules/smarty/plugins/modifier.replace.php','function'=>'smarty_modifier_replace',),));
?>

<li><a class="<?php if ($_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['pid'] == 0 && $_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['new']) {
if ($_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['sticky'] > 0 && $_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['locked'] == 1) {?>threadnew-sticky-locked<?php } elseif ($_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['sticky'] > 0) {?>threadnew-sticky<?php } elseif ($_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['locked'] == 1) {?>threadnew-locked<?php } else { ?>threadnew<?php }
} elseif ($_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['pid'] == 0) {
if ($_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['sticky'] > 0 && $_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['locked'] == 1) {?>thread-sticky-locked<?php } elseif ($_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['sticky'] > 0) {?>thread-sticky<?php } elseif ($_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['locked'] == 1) {?>thread-locked<?php } else { ?>thread<?php }
} elseif ($_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['pid'] != 0 && $_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['new']) {?>replynew<?php } else { ?>reply<?php }
if ($_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['is_read']) {?> read<?php }?>" href="index.php?id=<?php echo $_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['id'];?>
"<?php if ($_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['spam'] == 1) {?> title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'spam');?>
"<?php }?>><?php if ($_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['spam'] == 1) {?><span class="spam"><?php echo $_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['subject'];?>
</span><?php } else {
echo $_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['subject'];
}?></a><?php if ($_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['no_text']) {?> <img class="no-text" src="<?php echo $_smarty_tpl->tpl_vars['THEMES_DIR']->value;?>
/<?php echo $_smarty_tpl->tpl_vars['theme']->value;?>
/images/no_text.png" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'no_text_title');?>
" alt="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'no_text_alt');?>
" width="11" height="9" /><?php }?> - <strong><?php if ($_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['user_type'] == 2) {?><span class="admin registered_user" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'administrator_title');?>
"><?php echo $_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['name'];?>
</span><?php } elseif ($_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['user_type'] == 1) {?><span class="mod registered_user" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'moderator_title');?>
"><?php echo $_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['name'];?>
</span><?php } elseif ($_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['user_id'] > 0) {?><span class="registered_user"><?php echo $_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['name'];?>
</span><?php } else {
echo $_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['name'];
}?></strong>, <span id="p<?php echo $_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['id'];?>
" class="tail"><?php echo $_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['formated_time'];
if ($_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['pid'] == 0) {?> <a href="index.php?mode=thread&amp;id=<?php echo $_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['id'];?>
" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'open_whole_thread');?>
"><img src="<?php echo $_smarty_tpl->tpl_vars['THEMES_DIR']->value;?>
/<?php echo $_smarty_tpl->tpl_vars['theme']->value;?>
/images/complete_thread.png" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'open_whole_thread');?>
" alt="[*]" width="11" height="11" /></a><?php }
if ($_smarty_tpl->tpl_vars['admin']->value || $_smarty_tpl->tpl_vars['mod']->value) {?> <a id="marklink_<?php echo $_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['id'];?>
" href="index.php?mode=posting&amp;mark=<?php echo $_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['id'];?>
" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'mark_linktitle');?>
"><?php if ($_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['marked'] == 0) {?><img id="markimg_<?php echo $_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['id'];?>
" src="<?php echo $_smarty_tpl->tpl_vars['THEMES_DIR']->value;?>
/<?php echo $_smarty_tpl->tpl_vars['theme']->value;?>
/images/unmarked.png" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'mark_linktitle');?>
" alt="[○]" width="11" height="11" /><?php } else { ?><img id="markimg_<?php echo $_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['id'];?>
" src="<?php echo $_smarty_tpl->tpl_vars['THEMES_DIR']->value;?>
/<?php echo $_smarty_tpl->tpl_vars['theme']->value;?>
/images/marked.png" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'unmark_linktitle');?>
" alt="[●]" width="11" height="11" /><?php }?></a> <a href="index.php?mode=posting&amp;delete_posting=<?php echo $_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['id'];?>
&amp;csrf_token=<?php echo $_smarty_tpl->tpl_vars['CSRF_TOKEN']->value;?>
&amp;back=index" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'delete_posting_title');?>
"><img src="<?php echo $_smarty_tpl->tpl_vars['THEMES_DIR']->value;?>
/<?php echo $_smarty_tpl->tpl_vars['theme']->value;?>
/images/delete_posting.png" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'delete_posting_title');?>
" alt="[x]" width="9" height="9" /></a><?php }
if ($_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['category_name'] && $_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['pid'] == 0 && $_smarty_tpl->tpl_vars['category']->value <= 0) {?> <a href="index.php?mode=index&amp;category=<?php echo $_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['category'];?>
" title="<?php echo htmlspecialchars(smarty_modifier_replace($_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'change_category_link'),"[category]",$_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['category_name']), ENT_QUOTES, 'UTF-8', true);?>
"><span class="category">(<?php echo $_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['category_name'];?>
)</span></a><?php }
if ($_smarty_tpl->tpl_vars['fold_threads']->value == 1 && $_smarty_tpl->tpl_vars['data']->value[$_smarty_tpl->tpl_vars['element']->value]['pid'] == 0 && $_smarty_tpl->tpl_vars['replies']->value[$_smarty_tpl->tpl_vars['thread']->value] > 0) {?> <span class="replies" title="<?php if ($_smarty_tpl->tpl_vars['replies']->value[$_smarty_tpl->tpl_vars['thread']->value] == 1) {
echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'one_reply');
} else {
echo smarty_modifier_replace($_smarty_tpl->smarty->ext->configload->_getConfigVariable($_smarty_tpl, 'several_replies'),"[replies]",$_smarty_tpl->tpl_vars['replies']->value[$_smarty_tpl->tpl_vars['thread']->value]);
}?>">(<?php echo $_smarty_tpl->tpl_vars['replies']->value[$_smarty_tpl->tpl_vars['thread']->value];?>
)</span><?php }?></span>
<?php if (is_array($_smarty_tpl->tpl_vars['child_array']->value[$_smarty_tpl->tpl_vars['element']->value])) {?>
<ul class="<?php if ($_smarty_tpl->tpl_vars['level']->value < $_smarty_tpl->tpl_vars['settings']->value['deep_reply']) {?>reply<?php } elseif ($_smarty_tpl->tpl_vars['level']->value >= $_smarty_tpl->tpl_vars['settings']->value['deep_reply'] && $_smarty_tpl->tpl_vars['level']->value < $_smarty_tpl->tpl_vars['settings']->value['very_deep_reply']) {?>deep-reply<?php } else { ?>very-deep-reply<?php }
if ($_smarty_tpl->tpl_vars['fold_threads']->value == 1) {?> js-display-none<?php }?>"><?php
$_from = $_smarty_tpl->smarty->ext->_foreach->init($_smarty_tpl, $_smarty_tpl->tpl_vars['child_array']->value[$_smarty_tpl->tpl_vars['element']->value], 'child');
if ($_from !== null) {
foreach ($_from as $_smarty_tpl->tpl_vars['child']->value) {
$_smarty_tpl->smarty->ext->_tplFunction->callTemplateFunction($_smarty_tpl, 'tree', array('element'=>$_smarty_tpl->tpl_vars['child']->value,'level'=>$_smarty_tpl->tpl_vars['level']->value+1), true);
}
}
$_smarty_tpl->smarty->ext->_foreach->restore($_smarty_tpl, 1);?></ul><?php }?></li><?php
}}
/*/ smarty_template_function_tree_10743639866a00c399414370_31842828 */
}
