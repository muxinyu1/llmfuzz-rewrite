<?php
/* Smarty version 3.1.32, created on 2026-05-10 17:42:09
  from '/var/www/html/themes/default/subtemplates/subnavigation_2.inc.tpl' */

/* @var Smarty_Internal_Template $_smarty_tpl */
if ($_smarty_tpl->_decodeProperties($_smarty_tpl, array (
  'version' => '3.1.32',
  'unifunc' => 'content_6a00c371712a10_60672258',
  'has_nocache_code' => false,
  'file_dependency' => 
  array (
    '668777297491e207a8be2d1881f00eb9419fe001' => 
    array (
      0 => '/var/www/html/themes/default/subtemplates/subnavigation_2.inc.tpl',
      1 => 1778433611,
      2 => 'file',
    ),
  ),
  'includes' => 
  array (
  ),
),false)) {
function content_6a00c371712a10_60672258 (Smarty_Internal_Template $_smarty_tpl) {
if ($_smarty_tpl->tpl_vars['mode']->value == 'index') {?>
<ul id="subnavmenu"><li><a class="refresh" href="index.php?refresh=1&amp;category=<?php echo $_smarty_tpl->tpl_vars['category']->value;?>
" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'refresh_linktitle');?>
" rel="nofollow"><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'refresh_link');?>
</a></li><li><?php if ($_smarty_tpl->tpl_vars['thread_order']->value == 0) {?><a class="order-1" href="index.php?mode=index&amp;thread_order=1" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'order_link_title_1');?>
" rel="nofollow"><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'order_link');?>
</a><?php } else { ?><a class="order-2" href="index.php?mode=index&amp;thread_order=0" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'order_link_title_2');?>
" rel="nofollow"><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'order_link');?>
</a><?php }?></li><li><?php if ($_smarty_tpl->tpl_vars['usersettings']->value['fold_threads'] == 0) {?><a class="fold-1" href="index.php?fold_threads=1" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'fold_threads_linktitle');?>
"><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'fold_threads');?>
</a><?php } else { ?><a class="fold-2" href="index.php?fold_threads=0" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'expand_threads_linktitle');?>
"><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'expand_threads');?>
</a><?php }?></li><li><?php if ($_smarty_tpl->tpl_vars['usersettings']->value['user_view'] == 0) {?><a class="tableview" href="index.php?toggle_view=1" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'table_view_linktitle');?>
"><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'table_view');?>
</a><?php } else { ?><a class="threadview" href="index.php?toggle_view=0" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'thread_view_linktitle');?>
"><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'thread_view');?>
</a><?php }?></li></ul>
<?php } elseif ($_smarty_tpl->tpl_vars['mode']->value == 'entry') {?>
<ul id="subnavmenu"><li><a class="openthread" href="index.php?mode=thread&amp;id=<?php echo $_smarty_tpl->tpl_vars['tid']->value;?>
#p<?php echo $_smarty_tpl->tpl_vars['id']->value;?>
" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'open_in_thread_linktitle');?>
"><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'open_in_thread_link');?>
</a></li></ul>
<?php } elseif ($_smarty_tpl->tpl_vars['mode']->value == 'thread') {?>
<ul id="subnavmenu"><li><?php if ($_smarty_tpl->tpl_vars['usersettings']->value['thread_display'] == 0) {?><a class="linear" href="index.php?mode=thread&amp;id=<?php echo $_smarty_tpl->tpl_vars['id']->value;?>
&amp;toggle_thread_display=1" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'thread_linear_linktitle');?>
"><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'thread_linear');?>
</a><?php } else { ?><a class="hierarchic" href="index.php?mode=thread&amp;id=<?php echo $_smarty_tpl->tpl_vars['id']->value;?>
&amp;toggle_thread_display=0" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'thread_hierarchical_linktitle');?>
"><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'thread_hierarchical');?>
</a><?php }?></li>
</ul>
<?php }
if ($_smarty_tpl->tpl_vars['categories']->value && $_smarty_tpl->tpl_vars['mode']->value == 'index') {?>
<form action="index.php" method="get" accept-charset="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'charset');?>
"><div>
<input type="hidden" name="mode" value="<?php echo $_smarty_tpl->tpl_vars['mode']->value;?>
" />
&nbsp;<select class="small" size="1" name="category" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'category_title');?>
">
<option value="0"<?php if ($_smarty_tpl->tpl_vars['category']->value == 0) {?> selected="selected"<?php }?>><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'all_categories');?>
</option>
<?php if ($_smarty_tpl->tpl_vars['category_selection']->value) {?><option value="-1"<?php if ($_smarty_tpl->tpl_vars['category']->value == -1) {?> selected="selected"<?php }?>><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'my_category_selection');?>
</option><?php }
$_from = $_smarty_tpl->smarty->ext->_foreach->init($_smarty_tpl, $_smarty_tpl->tpl_vars['categories']->value, 'val', false, 'key');
if ($_from !== null) {
foreach ($_from as $_smarty_tpl->tpl_vars['key']->value => $_smarty_tpl->tpl_vars['val']->value) {
if ($_smarty_tpl->tpl_vars['key']->value != 0) {?><option value="<?php echo $_smarty_tpl->tpl_vars['key']->value;?>
"<?php if ($_smarty_tpl->tpl_vars['key']->value == $_smarty_tpl->tpl_vars['category']->value) {?> selected="selected"<?php }?>><?php echo $_smarty_tpl->tpl_vars['val']->value;?>
</option><?php }
}
}
$_smarty_tpl->smarty->ext->_foreach->restore($_smarty_tpl, 1);?>
</select><noscript><div class="inline"><input class="small" type="submit" value="&raquo;" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'go');?>
" /></div></noscript></div></form><?php }
if ($_smarty_tpl->tpl_vars['pagination_top']->value) {?>
&nbsp; <?php if ($_smarty_tpl->tpl_vars['pagination_top']->value['previous']) {?><a href="index.php?mode=<?php echo $_smarty_tpl->tpl_vars['mode']->value;?>
&amp;page=<?php echo $_smarty_tpl->tpl_vars['pagination_top']->value['previous'];
if ($_smarty_tpl->tpl_vars['category']->value) {?>&amp;category=<?php echo $_smarty_tpl->tpl_vars['category']->value;
}?>"><img class="previous" src="<?php echo $_smarty_tpl->tpl_vars['THEMES_DIR']->value;?>
/<?php echo $_smarty_tpl->tpl_vars['theme']->value;?>
/images/plain.png" alt="[&laquo;]" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'previous_page_link_title');?>
" width="6" height="11" /></a><?php }?>
<form action="index.php" method="get"><div class="inline">
<input type="hidden" name="mode" value="<?php echo $_smarty_tpl->tpl_vars['mode']->value;?>
" />
<?php if ($_smarty_tpl->tpl_vars['order']->value) {?><input type="hidden" name="order" value="<?php echo $_smarty_tpl->tpl_vars['order']->value;?>
" /><?php }
if ($_smarty_tpl->tpl_vars['category']->value) {?><input type="hidden" name="category" value="<?php echo $_smarty_tpl->tpl_vars['category']->value;?>
" /><?php }?>
<select class="small" size="1" name="page" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'browse_page_title');?>
">
<?php
$_from = $_smarty_tpl->smarty->ext->_foreach->init($_smarty_tpl, $_smarty_tpl->tpl_vars['pagination_top']->value['items'], 'item');
if ($_from !== null) {
foreach ($_from as $_smarty_tpl->tpl_vars['item']->value) {
if ($_smarty_tpl->tpl_vars['item']->value != 0) {?><option value="<?php echo $_smarty_tpl->tpl_vars['item']->value;?>
"<?php if ($_smarty_tpl->tpl_vars['item']->value == $_smarty_tpl->tpl_vars['page']->value) {?> selected="selected"<?php }?>><?php echo $_smarty_tpl->tpl_vars['item']->value;?>
</option><?php }
}
}
$_smarty_tpl->smarty->ext->_foreach->restore($_smarty_tpl, 1);?>
</select><noscript><div class="inline"><input class="small" type="submit" value="&raquo;" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'go');?>
" /></div></noscript>
</div></form>
<?php if ($_smarty_tpl->tpl_vars['pagination_top']->value['next']) {?><a href="index.php?mode=<?php echo $_smarty_tpl->tpl_vars['mode']->value;?>
&amp;page=<?php echo $_smarty_tpl->tpl_vars['pagination_top']->value['next'];
if ($_smarty_tpl->tpl_vars['category']->value) {?>&amp;category=<?php echo $_smarty_tpl->tpl_vars['category']->value;
}?>"><img class="next" src="<?php echo $_smarty_tpl->tpl_vars['THEMES_DIR']->value;?>
/<?php echo $_smarty_tpl->tpl_vars['theme']->value;?>
/images/plain.png" alt="[&raquo;]" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'next_page_link_title');?>
" width="6" height="11" /></a><?php }
}
}
}
