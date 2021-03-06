<cfoutput>
<div class="modal-header">
    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
	<h3><i class="icon-tasks"></i> CustomHTML Chooser</h3>
</div>
<div class="modal-body">
	#html.startForm(name="entryEditorSelectorForm")#

	<!--- Loader --->
	<div class="loaders floatRight" id="entryLoader">
		<i class="icon-spinner icon-spin icon-large icon-2x"></i>
	</div>
	
	<!--- Content Bar --->
	<div class="well well-small" id="contentBar">

		<!--- Filter Bar --->
		<div class="filterBar">
			<div>
				#html.label(field="entrySearch",content="Quick Search:",class="inline")#
				#html.textField(name="entrySearch",size="30",class="textfield",value=rc.search)#
			</div>
		</div>
	</div>

	<!--- Render tables out --->
	<div id="entriesContainer">
	#renderView(view="customHTML/editorSelectorEntries", module="contentbox-admin")#
	</div>
			
	#html.endForm()#
</div>
<!--- Button Bar --->
<div class="modal-footer">
	<button class="btn btn-danger" onclick="closeRemoteModal()"> Close </button>
</div>
</cfoutput>