<?php
/* Smarty version 3.1.32, created on 2026-05-10 17:42:09
  from '/var/www/html/themes/default/subtemplates/bookmark.inc.tpl' */

/* @var Smarty_Internal_Template $_smarty_tpl */
if ($_smarty_tpl->_decodeProperties($_smarty_tpl, array (
  'version' => '3.1.32',
  'unifunc' => 'content_6a00c3717b9233_45068182',
  'has_nocache_code' => false,
  'file_dependency' => 
  array (
    'c11f56aa4db069853d7007984a8f79f5de7a8902' => 
    array (
      0 => '/var/www/html/themes/default/subtemplates/bookmark.inc.tpl',
      1 => 1778433611,
      2 => 'file',
    ),
  ),
  'includes' => 
  array (
  ),
),false)) {
function content_6a00c3717b9233_45068182 (Smarty_Internal_Template $_smarty_tpl) {
$_smarty_tpl->_checkPlugins(array(0=>array('file'=>'/var/www/html/modules/smarty/plugins/function.cycle.php','function'=>'smarty_function_cycle',),1=>array('file'=>'/var/www/html/modules/smarty/plugins/modifier.replace.php','function'=>'smarty_modifier_replace',),));
$_smarty_tpl->smarty->ext->configLoad->_loadConfigFile($_smarty_tpl, $_smarty_tpl->tpl_vars['language_file']->value, "bookmark", 0);
?>


<?php if ($_smarty_tpl->tpl_vars['action']->value == 'bookmark') {?>
	<?php if ($_smarty_tpl->tpl_vars['total_bookmarks']->value > 0) {?>
		<table id="sortable" class="normaltab" border="0" cellpadding="5" cellspacing="1">
			<thead>
				<tr>
					<th><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'bookmark_title');?>
</th>
					<th><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'bookmark_user_name');?>
</th>
					<th><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'bookmark_creation_time');?>
</th>
					<th><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'bookmark_posting_time');?>
</th>
					<th>Tags</th>
					<th>&#160;</th>
				</tr>
			</thead>
			<tbody>
				<?php
$_from = $_smarty_tpl->smarty->ext->_foreach->init($_smarty_tpl, $_smarty_tpl->tpl_vars['bookmarkdata']->value, 'row');
if ($_from !== null) {
foreach ($_from as $_smarty_tpl->tpl_vars['row']->value) {
?>
					<?php echo smarty_function_cycle(array('values'=>"a,b",'assign'=>'c'),$_smarty_tpl);?>

					<tr id="id_<?php echo $_smarty_tpl->tpl_vars['row']->value['bid'];?>
" class="<?php echo $_smarty_tpl->tpl_vars['c']->value;?>
">
						<td><a href="index.php?id=<?php echo $_smarty_tpl->tpl_vars['row']->value['id'];?>
" title="<?php echo $_smarty_tpl->tpl_vars['row']->value['subject'];?>
"><strong><?php echo $_smarty_tpl->tpl_vars['row']->value['subject'];?>
</strong></a></td>
						<td><?php if ($_smarty_tpl->tpl_vars['row']->value['user_id'] > 0) {?><a href="index.php?mode=user&amp;show_user=<?php echo $_smarty_tpl->tpl_vars['row']->value['user_id'];?>
" title="<?php echo smarty_modifier_replace($_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'show_userdata_linktitle'),"[user]",$_smarty_tpl->tpl_vars['row']->value['user_name']);?>
"><?php }?><strong><?php echo $_smarty_tpl->tpl_vars['row']->value['user_name'];?>
</strong><?php if ($_smarty_tpl->tpl_vars['row']->value['user_id'] > 0) {?></a><?php }?></td>
						<td><span class="small"><?php echo $_smarty_tpl->tpl_vars['row']->value['bookmark_time'];?>
</span></td>
						<td><span class="small"><?php echo $_smarty_tpl->tpl_vars['row']->value['posting_time'];?>
</span></td>
						
						<td><span class="small">
							<?php
$_from = $_smarty_tpl->smarty->ext->_foreach->init($_smarty_tpl, $_smarty_tpl->tpl_vars['row']->value['tags'], 'tag', false, NULL, 'tags', array (
  'last' => true,
  'iteration' => true,
  'total' => true,
));
if ($_from !== null) {
foreach ($_from as $_smarty_tpl->tpl_vars['tag']->value) {
$_smarty_tpl->tpl_vars['__smarty_foreach_tags']->value['iteration']++;
$_smarty_tpl->tpl_vars['__smarty_foreach_tags']->value['last'] = $_smarty_tpl->tpl_vars['__smarty_foreach_tags']->value['iteration'] === $_smarty_tpl->tpl_vars['__smarty_foreach_tags']->value['total'];
?>
								<a title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'bookmark_filter_linktitle');?>
" href="index.php?mode=bookmarks&amp;filter=<?php echo $_smarty_tpl->tpl_vars['tag']->value['escaped'];?>
"><?php echo $_smarty_tpl->tpl_vars['tag']->value['display'];?>
</a><?php if (!(isset($_smarty_tpl->tpl_vars['__smarty_foreach_tags']->value['last']) ? $_smarty_tpl->tpl_vars['__smarty_foreach_tags']->value['last'] : null)) {?>, <?php }?>
							<?php
}
}
$_smarty_tpl->smarty->ext->_foreach->restore($_smarty_tpl, 1);?>
						</span></td>
						
						<td><a href="index.php?mode=bookmarks&amp;edit_bookmark=<?php echo $_smarty_tpl->tpl_vars['row']->value['bid'];?>
"><img class="control" src="<?php echo $_smarty_tpl->tpl_vars['THEMES_DIR']->value;?>
/<?php echo $_smarty_tpl->tpl_vars['theme']->value;?>
/images/edit.png" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'edit');?>
" alt="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'edit');?>
" width="16" height="16" /></a> &nbsp; <a href="index.php?mode=bookmarks&amp;delete_bookmark=<?php echo $_smarty_tpl->tpl_vars['row']->value['bid'];?>
"><img class="control" src="<?php echo $_smarty_tpl->tpl_vars['THEMES_DIR']->value;?>
/<?php echo $_smarty_tpl->tpl_vars['theme']->value;?>
/images/delete.png" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'delete');?>
" alt="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'delete');?>
" width="16" height="16"/></a> &nbsp; <a href="index.php?mode=bookmarks&amp;move_up_bookmark=<?php echo $_smarty_tpl->tpl_vars['row']->value['bid'];?>
"><img class="control" src="<?php echo $_smarty_tpl->tpl_vars['THEMES_DIR']->value;?>
/<?php echo $_smarty_tpl->tpl_vars['theme']->value;?>
/images/arrow_up.png" alt="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'up');?>
" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'up');?>
" width="16" height="16" /></a>&nbsp;<a href="index.php?mode=bookmarks&amp;move_down_bookmark=<?php echo $_smarty_tpl->tpl_vars['row']->value['bid'];?>
"><img class="control" src="<?php echo $_smarty_tpl->tpl_vars['THEMES_DIR']->value;?>
/<?php echo $_smarty_tpl->tpl_vars['theme']->value;?>
/images/arrow_down.png" alt="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'down');?>
" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'down');?>
" width="16" height="16" /></a></td>
					</tr>
				<?php
}
}
$_smarty_tpl->smarty->ext->_foreach->restore($_smarty_tpl, 1);?>
			</tbody>
		</table>
		<?php if ($_smarty_tpl->tpl_vars['filter']->value) {?>
			<p><a href="index.php?mode=bookmarks" title="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'clear_bookmark_filter_linktitle');?>
"><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'clear_bookmark_filter_linkname');?>
</a></p>
		<?php }?>
	<?php } else { ?>
		<p><em><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'no_bookmarks');?>
</em></p>
	<?php }?>
	
<?php } elseif ($_smarty_tpl->tpl_vars['action']->value == 'delete_bookmark') {?>
	<?php if ($_smarty_tpl->tpl_vars['bookmark']->value) {?>
		<p class="caution"><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'caution');?>
</p>
		<p><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'delete_bookmark_confirm');?>
</p>
		<p><strong><?php echo $_smarty_tpl->tpl_vars['bookmark']->value['subject'];?>
</strong></p>
		<form action="index.php" method="post" accept-charset="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'charset');?>
">
			<div>
				<input type="hidden" name="mode" value="bookmarks" />
				<input type="hidden" name="id" value="<?php echo $_smarty_tpl->tpl_vars['bookmark']->value['id'];?>
" />
				<input type="submit" name="delete_bookmark_submit" value="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'delete_bookmark_submit');?>
" />
			</div>
		</form>
	<?php } else { ?>
		<p><em><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'no_bookmarks');?>
</em></p>
	<?php }?>
	
<?php } elseif ($_smarty_tpl->tpl_vars['action']->value == 'edit_bookmark') {?>
	<?php if ($_smarty_tpl->tpl_vars['errors']->value) {?>
		<p class="caution"><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'error_headline');?>
</p>
		<ul style="margin-bottom:25px;">
		<?php
$__section_mysec_0_loop = (is_array(@$_loop=$_smarty_tpl->tpl_vars['errors']->value) ? count($_loop) : max(0, (int) $_loop));
$__section_mysec_0_total = $__section_mysec_0_loop;
$_smarty_tpl->tpl_vars['__smarty_section_mysec'] = new Smarty_Variable(array());
if ($__section_mysec_0_total !== 0) {
for ($__section_mysec_0_iteration = 1, $_smarty_tpl->tpl_vars['__smarty_section_mysec']->value['index'] = 0; $__section_mysec_0_iteration <= $__section_mysec_0_total; $__section_mysec_0_iteration++, $_smarty_tpl->tpl_vars['__smarty_section_mysec']->value['index']++){
?>
			<li><?php $_smarty_tpl->_assignInScope('error', $_smarty_tpl->tpl_vars['errors']->value[(isset($_smarty_tpl->tpl_vars['__smarty_section_mysec']->value['index']) ? $_smarty_tpl->tpl_vars['__smarty_section_mysec']->value['index'] : null)]);
echo smarty_modifier_replace($_smarty_tpl->smarty->ext->configload->_getConfigVariable($_smarty_tpl, $_smarty_tpl->tpl_vars['error']->value),"[word]",$_smarty_tpl->tpl_vars['word']->value);?>
</li>
		<?php
}
}
?>
		</ul>
	<?php }?>

	<?php if ($_smarty_tpl->tpl_vars['bookmark']->value) {?>
		<form action="index.php" method="post" class="normalform" accept-charset="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'charset');?>
">
			<div>
				<input type="hidden" name="mode" value="bookmarks" />
				<input type="hidden" name="id" value="<?php echo $_smarty_tpl->tpl_vars['bookmark']->value['id'];?>
" />
				<label for="bookmark" class="input"><strong><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'edit_bookmark');?>
</strong></label><br />
				<input type="text" id="bookmark" name="bookmark" value="<?php echo $_smarty_tpl->tpl_vars['bookmark']->value['title'];?>
" maxlength="255" size="25" /><br /><br />
				<label for="tags" class="input"><strong><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'edit_tags');?>
</strong></label><br />
				<input type="text" id="tags" name="tags" value="<?php echo $_smarty_tpl->tpl_vars['bookmark']->value['tags'];?>
" maxlength="255" size="25" />&nbsp;<span class="xsmall"><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'edit_tags_note');?>
</span><br /><br />
				<input type="submit" name="edit_bookmark_submit" value="<?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'submit_button_ok');?>
" />
			</div>
		</form>
	<?php } else { ?>
		<p><em><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'no_bookmarks');?>
</em></p>
	<?php }
} else { ?>
	<p><em><?php echo $_smarty_tpl->smarty->ext->configLoad->_getConfigVariable($_smarty_tpl, 'no_bookmarks');?>
</em></p>
<?php }
}
}
