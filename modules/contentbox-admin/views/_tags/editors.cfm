<cfoutput>
<!--- Load Editor Custom Assets --->
#html.addAsset(prc.cbroot & "/includes/css/date.css")#
<!--- Editor Javascript --->
<script type="text/javascript">
// Load Custom Editor Assets, Functions, etc.
#prc.oEditorDriver.loadAssets()#

// Quick preview for content
function previewContent(){
	// Open the preview window for content
	openRemoteModal( getPreviewSelectorURL(), 
					 { content: getEditorContent(), 
					   layout: $("##layout").val(),
					   title: $("##title").val(),
					   slug: $("##slug").val(),
					   contentType : $("##contentType").val(),
					   markup : $("##markup").val() },
					 "95%",
					 "85%",
                     true);
}
// Set the actual publishing date to now
function publishNow(){
	var fullDate = new Date();
	$("##publishedDate").val( getToday() );
	$("##publishedHour").val( fullDate.getHours() );
	$("##publishedMinute").val( fullDate.getMinutes() );
}
// quick save for pages
function quickSave(){
	// Draft it
	$isPublished.val('false');
	// Validation of Form First before quick save
	if( !$targetEditorForm.valid() ){
		return false;
	}
	// Commit Changelog default if none specified, most likely changelogs are not mandatory
	if( !$changelog.val().length ){
		$changelog.val( "quick save" );
	}
	// Activate Loader
	toggleLoaderBar();
	// Save current content, just in case
	$content.val( getEditorContent() );
	// Post it
	$.post($targetEditorSaveURL, $targetEditorForm.serialize(), function(data){
		// Save new id
		$contentID.val( data.CONTENTID );
		// finalize
		$changelog.val( '' );
		$uploaderBarLoader.fadeOut( 1500 );
		$uploaderBarStatus.html( 'Draft Quick Saved!' );
		$isPublished.val( 'true' );
	},"json");

	return false;
}
/**
 * Setup the editors. 
 * TODO: Move this to a more OOish approach, don't like it.
 * @param $theForm The form container for the editor
 * @param withExcerpt Using excerpt or not apart from the main 'content' object
 * @param saveURL The URL used for saving the content asynchronously
 * @param withChangelogs Using changelogs or not in the editing forms
 */
function setupEditors($theForm, withExcerpt, saveURL, withChangelogs){
	// Setup global editor elements
	$targetEditorForm   	= $theForm;
	$targetEditorSaveURL 	= saveURL;
	$uploaderBarLoader 		= $targetEditorForm.find("##uploadBarLoader");
	$uploaderBarStatus 		= $targetEditorForm.find("##uploadBarLoaderStatus");
	$excerpt				= $targetEditorForm.find("##excerpt");
	$content 				= $targetEditorForm.find("##content");
	$isPublished 			= $targetEditorForm.find("##isPublished");
	$contentID				= $targetEditorForm.find("##contentID");
	$changelog				= $targetEditorForm.find("##changelog");
	
	// with excerpt
	if( withExcerpt == null ){ withExcerpt = true; }
	// with changelogs
	if( withChangelogs == null ){ withChangelogs = true; }
	
	// Startup the choosen editor
	#prc.oEditorDriver.startup()#

	// Activate Date fields
	$("[type=date]").datepicker();
	$(".datepicker").datepicker();

	// Activate Form Validator
	$targetEditorForm.validate({
    	ignore: 'content',
    	success:function(e,els){ 
    		needConfirmation=false; 
    	},
        submitHandler: function( form ) {
        	// weird issue in jQuery validator where it won't validate hidden fields
            // so call updateElement() to get content for hidden textarea
        	CKEDITOR.instances.content.updateElement();
            // validate element
    		var el = $( '##content' );
            // if it's valid, submit form
            if( el.val().length ) {
            	form.submit();
            }
            // otherwise, show error
            else {
            	alert( 'Please enter some content!' );
           	}
        }
    });

	// Changelog mandatory?
	if( withChangelogs ){
		$targetEditorForm.find( "##changelog" ).attr( "required", #prc.cbSettings.cb_versions_commit_mandatory# );
	}
	// Activate blur slugify on titles
	var $title = $targetEditorForm.find("##title");
	$title.blur(function(){
		if( $targetEditorForm.find("##slug").size() ){
			createPermalink( $title.val() );
		}
	});
	// Activate permalink blur
	$targetEditorForm.find("##slug").blur(function(){
		permalinkUniqueCheck()
	});
	// Editor dirty checks
	window.onbeforeunload = askLeaveConfirmation;
	needConfirmation = true;
	// counters
	$("##htmlKeywords").keyup(function(){
		$("##html_keywords_count").html( $("##htmlKeywords").val().length );
	});
	$("##htmlDescription").keyup(function(){
		$("##html_description_count").html( $("##htmlDescription").val().length );
	});
}

// Switch Editors
function switchEditor(editorType){
	// destroy the editor
	#prc.oEditorDriver.shutdown()#
	// Save work
	if( confirm( "Would you like to save your work before switching editors?" ) ){
		$changelog.val( 'Editor Change Quick Save' );
		quickSave();
	}
	// Call change user editor preference
	$.ajax({
		url : '#event.buildLink(prc.xehAuthorEditorSave)#',
		data : {editor: $("##contentEditorChanger").val()},
		async : false,
		success : function(data){
			// Once changed, reload the page.
			location.reload();
		}
	});
}

// Ask for leave confirmations
function askLeaveConfirmation(){
	if ( checkIsDirty() && needConfirmation ){
   		return "You have unsaved changes.";
   	}
}

// Create Permalinks
function createPermalink(){
	if( !$("##title").val().length ){ return; }
	$slug = $("##slug").fadeOut();
	$.get( '#event.buildLink( prc.xehSlugify )#', {slug:$("##title").val()}, function(data){
		$slug.fadeIn().val( $.trim(data) );
	} );
	permalinkUniqueCheck();
}
function permalinkUniqueCheck(){
	if( !$("##slug").val().length ){ return; }
	// Verify unique
	$.getJSON( '#event.buildLink( prc.xehSlugCheck )#', {slug:$("##slug").val(), contentID: $("##contentID").val()}, function(data){
		if( !data.UNIQUE ){
			$("##slugCheckErrors").html("The permalink slug you entered is already in use, please enter another one or modify it.").addClass("alert");
		}
		else{
			$("##slugCheckErrors").html("").removeClass("alert");
		}
	} );
}

// Toggle drafts on for saving
function toggleDraft(){
	needConfirmation = false;
	$isPublished.val('false');
}

// Widget Plugin Integration
function getWidgetSelectorURL(){ return '#event.buildLink(prc.cbAdminEntryPoint & ".widgets.editorselector")#';}
// Widget Preview Integration
function getWidgetPreviewURL(){ return '#event.buildLink( prc.cbAdminEntryPoint & ".widgets.preview" )#'; }
// Widget Editor Integration
function getWidgetEditorURL(){ return '#event.buildLink( prc.cbAdminEntryPoint & ".widgets.editinstance" )#'; }
// Widget Args Integration
function getWidgetRenderArgsURL(){ return '#event.buildLink( prc.cbAdminEntryPoint & ".widgets.renderargs" )#'; }
// Page Selection Integration
function getPageSelectorURL(){ return '#event.buildLink(prc.cbAdminEntryPoint & ".pages.editorselector")#';}
// Entry Selection Integration
function getEntrySelectorURL(){ return '#event.buildLink(prc.cbAdminEntryPoint & ".entries.editorselector")#';}
// Custom HTML Selection Integration
function getCustomHTMLSelectorURL(){ return '#event.buildLink(prc.cbAdminEntryPoint & ".customHTML.editorselector")#';}
// Preview Integration
function getPreviewSelectorURL(){ return '#event.buildLink(prc.cbAdminEntryPoint & ".content.preview")#';}
// Module Link Building
function getModuleURL(module, event, queryString){
	var returnURL = "";
	$.ajax({
		url : '#event.buildLink(prc.cbAdminEntryPoint & ".modules.buildModuleLink")#',
		data : {module: module, moduleEvent: event, moduleQS: queryString},
		async : false,
		success : function(data){
			returnURL = data;
		}
	});
	return $.trim( returnURL );
}
// Toggle upload/saving bar
function toggleLoaderBar(){
	// Activate Loader
	$uploaderBarStatus.html("Saving...");
	$uploaderBarLoader.slideToggle();
}
</script>
</cfoutput>