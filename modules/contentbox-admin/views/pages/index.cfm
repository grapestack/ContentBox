﻿<cfoutput>
<div class="row-fluid">
	<!--- main content --->
	<div class="span9" id="main-content">
		<div class="box">
			<!--- Body Header --->
			<div class="header">
				<i class="icon-file-alt icon-large"></i>
				Pages
				<cfif len(rc.searchPages)><span class="badge">Search: #rc.searchPages#</span></cfif>
				<cfif prc.isFiltering> <span class="badge">Filtered View</span></cfif>
			</div>
			<!--- Body --->
			<div class="body">
	
				<!--- MessageBox --->
				#getPlugin("MessageBox").renderit()#
				
				<!---Import Log --->
				<cfif flash.exists( "importLog" )>
				<div class="consoleLog">#flash.get( "importLog" )#</div>
				</cfif>
	
				<!--- pageForm --->
				#html.startForm(name="pageForm",action=prc.xehPageRemove)#
				#html.hiddenField(name="contentStatus",value="")#
				#html.hiddenField(name="contentID",value="")#
				#html.hiddenField(name="parent",value=event.getValue("parent",""))#
	
				<!--- Info Bar --->
				<cfif NOT prc.cbSettings.cb_comments_enabled>
					<div class="alert alert-info">
						<i class="icon-exclamation-sign icon-large"></i>
						Comments are currently disabled site-wide!
					</div>
				</cfif>
	
				<!--- Content Bar --->
				<div class="well well-small" id="contentBar">
	
					<!--- Create Butons --->
					<cfif prc.oAuthor.checkPermission("PAGES_ADMIN") or prc.oAuthor.checkPermission("PAGES_EDITOR")>
					<div class="buttonBar">
					    <div class="btn-group">
					    	<a class="btn dropdown-toggle" data-toggle="dropdown" href="##">
								Global Actions <span class="caret"></span>
							</a>
					    	<ul class="dropdown-menu">
					    		<li><a href="javascript:bulkChangeStatus('draft')"><i class="icon-ban-circle"></i> Draft Selected</a></li>
								<li><a href="javascript:bulkChangeStatus('publish')"><i class="icon-ok-sign"></i> Publish Selected</a></li>
								<li><a href="javascript:importContent()"><i class="icon-upload-alt"></i> Import</a></li>
								<li class="dropdown-submenu">
									<a href="##"><i class="icon-download icon-large"></i> Export All</a>
									<ul class="dropdown-menu text-left">
										<li><a href="#event.buildLink(linkto=prc.xehPageExportAll)#.json" target="_blank"><i class="icon-code"></i> as JSON</a></li>
										<li><a href="#event.buildLink(linkto=prc.xehPageExportAll)#.xml" target="_blank"><i class="icon-sitemap"></i> as XML</a></li>
									</ul>
								</li>
					    	</ul>
					    </div>
						<button class="btn btn-danger" onclick="return to('#event.buildLink(linkTo=prc.xehPageEditor)#/parentID/#event.getValue('parent','')#');">Create Page</button>
					</div>
					</cfif>
	
					<!--- Filter Bar --->
					<div class="filterBar">
						<div>
							#html.label(field="pageFilter",content="Quick Filter:",class="inline")#
							#html.textField(name="pageFilter",size="30",class="textfield")#
						</div>
					</div>
				</div>
	
				<!--- Location Bar --->
				<cfif structKeyExists(rc, "parent") AND len( rc.parent )>
				<div class="breadcrumb">
				  <a href="#event.buildLink(prc.xehPages)#"><i class="icon-home icon-large"></i></a> 
				  #getMyPlugin(plugin="PageBreadcrumbVisitor",module="contentbox-admin").visit(prc.page, event.buildLink(prc.xehPages))#
				</div>
				</cfif>
				
				<!--- pages --->
				<table name="pages" id="pages" class="tablesorter table table-striped table-hover" width="98%">
					<thead>
						<tr>
							<th id="checkboxHolder" class="{sorter:false}" width="20"><input type="checkbox" onClick="checkAll(this.checked,'contentID')"/></th>
							<th>Name</th>
							<th width="40" class="center"><i class="icon-th-list icon-large" title="Show in Menu"></i></th>
							<th width="40" class="center"><i class="icon-globe icon-large" title="Published"></i></th>
							<th width="40" class="center"><i class="icon-signal icon-large" title="Hits"></i></th>
							<th width="100" class="center {sorter:false}">Actions</th>
						</tr>
					</thead>
	
					<tbody>
						<cfloop array="#prc.pages#" index="page">
						<tr id="contentID-#page.getContentID()#" data-contentID="#page.getContentID()#"
							<cfif page.isExpired()>
								class="error"
							<cfelseif page.isPublishedInFuture()>
								class="success"
							<cfelseif !page.isContentPublished()>
								class="warning"
							</cfif>
							<cfif page.getNumberOfChildren()>ondblclick="to('#event.buildLink(prc.xehPages)#/parent/#page.getContentID()#')"</cfif>>
							<!--- check box --->
							<td>
								<input type="checkbox" name="contentID" id="contentID" value="#page.getContentID()#" />
							</td>
							<td>
								<!--- Children Dig Deeper --->
								<cfif page.getNumberOfChildren()>
									<a href="#event.buildLink(prc.xehPages)#/parent/#page.getContentID()#" class="hand-cursor" title="View Child Pages (#page.getNumberOfChildren()#)"><i class="icon-plus-sign icon-large text"></i></a>
								<cfelse>
									<i class="icon-circle-blank icon-large"></i>
								</cfif>
								<!--- Title --->
								<cfif prc.oAuthor.checkPermission("PAGES_EDITOR") OR prc.oAuthor.checkPermission("PAGES_ADMIN")>
									<a href="#event.buildLink(prc.xehPageEditor)#/contentID/#page.getContentID()#" title="Edit #page.getTitle()#">#page.getTitle()#</a>
								<cfelse>
									#page.getTitle()#
								</cfif>
								<!--- password protected --->
								<cfif page.isPasswordProtected()>
									<i class="icon-lock"></i>
								</cfif>
							</td>
							<td class="center">
								<cfif page.getShowInMenu()>
									<i class="icon-ok icon-large textGreen"></i>
								<cfelse>
									<i class="icon-remove icon-large textRed"></i>
								</cfif>
							</td>
							<td class="center">
								<cfif page.isExpired()>
									<i class="icon-time icon-large textRed" title="Page has expired on ( (#page.getDisplayExpireDate()#))"></i>
									<span class="hidden">expired</span>
								<cfelseif page.isPublishedInFuture()>
									<i class="icon-fighter-jet icon-large textBlue" title="Page Publishes in the future (#page.getDisplayPublishedDate()#)"></i>
									<span class="hidden">published in future</span>
								<cfelseif page.isContentPublished()>
									<i class="icon-ok icon-large textGreen" title="Page Published"></i>
									<span class="hidden">published in future</span>
								<cfelse>
									<i class="icon-remove icon-large textRed" title="Page Draft"></i>
									<span class="hidden">draft</span>
								</cfif>
							</td>
							<td class="center"><span class="badge badge-info">#page.getHits()#</span></td>
							<td class="center">
								<!---Info Panel --->
								<a 	class="btn popovers" 
									data-contentID="#page.getContentID()#"
									data-toggle="popover"><i class="icon-info-sign icon-large"></i></a>
								<!---Info Panel --->
								<div id="infoPanel_#page.getContentID()#" class="hide">
									<!--- creator --->
									<i class="icon-user"></i>
									Created by <a href="mailto:#page.getCreatorEmail()#">#page.getCreatorName()#</a> on 
									#page.getDisplayCreatedDate()#
									</br>
									<!--- last edit --->
									<i class="icon-calendar"></i>
									Last edit by <a href="mailto:#page.getAuthorEmail()#">#page.getAuthorName()#</a> on 
									#page.getActiveContent().getDisplayCreatedDate()#
									</br>
									<!--- Categories --->
									<i class="icon-tag"></i> #page.getCategoriesList()#<br/>
									<!--- comments icon --->
									<cfif page.getallowComments()>
										<i class="icon-comments"></i> Open Comments
									<cfelse>
										<i class="icon-warning-sign"></i> Closed Comments
									</cfif>
									<!---Layouts --->
									<br/>
									<i class="icon-picture"></i> Layout: <strong>#page.getLayout()#</strong>
									<cfif len( page.getMobileLayout() )>
									<br/>
									<i class="icon-tablet"></i> Mobile Layout: <strong>#page.getMobileLayout()#</strong>
									</cfif>
								</div>
								
								<!--- Page Actions --->
								<div class="btn-group">
							    	<a class="btn dropdown-toggle" data-toggle="dropdown" href="##" title="Page Actions">
										<i class="icon-cogs icon-large"></i>
									</a>
							    	<ul class="dropdown-menu text-left pull-right">
							    		<cfif prc.oAuthor.checkPermission("PAGES_EDITOR") OR prc.oAuthor.checkPermission("PAGES_ADMIN")>
										<!--- Clone Command --->
										<li><a href="javascript:openCloneDialog('#page.getContentID()#','#URLEncodedFormat(page.getTitle())#')"><i class="icon-copy icon-large"></i> Clone</a></li>
										<!--- Create Child --->
										<li><a href="#event.buildLink(prc.xehPageEditor)#/parentID/#page.getContentID()#"><i class="icon-sitemap icon-large"></i> Create Child</a></li>
										<cfif prc.oAuthor.checkPermission("PAGES_ADMIN")>
										<!--- Delete Command --->
										<li><a href="javascript:remove('#page.getContentID()#')" class="confirmIt"
										  data-title="Delete Page?" data-message="This will delete the page and all of its sub-pages, are you sure?"><i id="delete_#page.getContentID()#" class="icon-trash icon-large"></i> Delete</a></li>
										</cfif>
										<!--- Edit Command --->
										<li><a href="#event.buildLink(prc.xehPageEditor)#/contentID/#page.getContentID()#"><i class="icon-edit icon-large"></i> Edit</a></li>
										</cfif>
										<cfif prc.oAuthor.checkPermission("PAGES_ADMIN")>
										<!--- Export --->
										<li class="dropdown-submenu pull-left">
											<a href="##"><i class="icon-download icon-large"></i> Export</a>
											<ul class="dropdown-menu text-left">
												<li><a href="#event.buildLink(linkto=prc.xehPageExport)#/contentID/#page.getContentID()#.json" target="_blank"><i class="icon-code"></i> as JSON</a></li>
												<li><a href="#event.buildLink(linkto=prc.xehPageExport)#/contentID/#page.getContentID()#.xml" target="_blank"><i class="icon-sitemap"></i> as XML</a></li>
											</ul>
										</li>
										</cfif>
										<!--- History Command --->
										<li><a href="#event.buildLink(prc.xehPageHistory)#/contentID/#page.getContentID()#"><i class="icon-time icon-large"></i> History</a></li>
										<!--- View in Site --->
										<li><a href="#prc.CBHelper.linkPage(page)#" target="_blank"><i class="icon-eye-open icon-large"></i> Open In Site</a></li>
							    	</ul>
							    </div>
								
								</td>
						</tr>
						</cfloop>
					</tbody>
				</table>
	
				<!--- Paging --->
				#prc.pagingPlugin.renderit(foundRows=prc.pagesCount, link=prc.pagingLink, asList=true)#
	
				#html.endForm()#
			</div>
		</div>
	</div>

	<!--- main sidebar --->
	<div class="span3" id="main-sidebar">
		<!--- Saerch Box --->
		<div class="small_box">
			<div class="header">
				<i class="icon-search"></i> Search
			</div>
			<div class="body<cfif len(rc.searchPages)> selected</cfif>">
				<!--- Search Form --->
				#html.startForm(name="authorSearchForm",action=prc.xehPageSearch)#
					#html.textField(label="Search:", name="searchPages", class="textfield input-block-level", size="16", title="Search all pages", value=event.getValue("searchPages",""))#
					<button type="submit" class="btn btn-danger">Search</button>
					<button class="btn" onclick="return to('#event.buildLink(prc.xehPages)#')">Clear</button>
				#html.endForm()#
			</div>
		</div>
	
		<!--- Filter Box --->
		<div class="small_box">
			<div class="header">
				<i class="icon-filter"></i> Filters
			</div>
			<div class="body<cfif prc.isFiltering> selected</cfif>">
				#html.startForm(name="pageFilterForm",action=prc.xehPageSearch)#
				<!--- Authors --->
				<label for="fAuthors">Authors: </label>
				<select name="fAuthors" id="fAuthors" class="input-block-level">
					<option value="all" <cfif rc.fAuthors eq "all">selected="selected"</cfif>>All Authors</option>
					<cfloop array="#prc.authors#" index="author">
					<option value="#author.getAuthorID()#" <cfif rc.fAuthors eq author.getAuthorID()>selected="selected"</cfif>>#author.getName()#</option>
					</cfloop>
				</select>
				<!--- Categories --->
				<label for="fCategories">Categories: </label>
				<select name="fCategories" id="fCategories" class="input-block-level">
					<option value="all" <cfif rc.fCategories eq "all">selected="selected"</cfif>>All Categories</option>
					<option value="none" <cfif rc.fCategories eq "none">selected="selected"</cfif>>Uncategorized</option>
					<cfloop array="#prc.categories#" index="category">
					<option value="#category.getCategoryID()#" <cfif rc.fCategories eq category.getCategoryID()>selected="selected"</cfif>>#category.getCategory()#</option>
					</cfloop>
				</select>
				<!--- Status --->
				<label for="fStatus">Page Status: </label>
				<select name="fStatus" id="fStatus" class="input-block-level">
					<option value="any"   <cfif rc.fStatus eq "any">selected="selected"</cfif>>Any Status</option>
					<option value="true"  <cfif rc.fStatus eq "true">selected="selected"</cfif>>Published</option>
					<option value="false" <cfif rc.fStatus eq "false">selected="selected"</cfif>>Draft</option>
				</select>
	
				<button type="submit" class="btn btn-danger">Apply Filters</button>
				<button class="btn" onclick="return to('#event.buildLink(prc.xehPages)#')">Reset</button>
				#html.endForm()#
			</div>
		</div>
	
		<!--- Help Box--->
		<div class="small_box" id="help_tips">
			<div class="header">
				<i class="icon-question-sign"></i> Help Tips
			</div>
			<div class="body">
				<ul class="tipList unstyled">
					<li><i class="icon-lightbulb icon-larg"></i> Right click on a row to activate quick look!</li>
					<li><i class="icon-lightbulb icon-larg"></i> Sorting is only done within your paging window</li>
					<li><i class="icon-lightbulb icon-larg"></i> Quick Filtering is only for viewed results</li>
					<li><i class="icon-lightbulb icon-larg"></i> Cloning does not copy comments or version history</li>
					<li><i class="icon-lightbulb icon-larg"></i> You can quickly order the pages by dragging the rows</li>
				</ul>
			</div>
		</div>
	</div>
</div>

<!--- Clone Dialog --->
<cfif prc.oAuthor.checkPermission("PAGES_EDITOR") OR prc.oAuthor.checkPermission("PAGES_ADMIN")>
<div id="cloneDialog" class="modal hide fade">
	<div id="modalContent">
	    <div class="modal-header">
	        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
	        <h3><i class="icon-copy"></i> Page Cloning</h3>
	    </div>
        #html.startForm(name="cloneForm", action=prc.xehPageClone, class="form-vertical")#
        <div class="modal-body">
			<p>By default, all internal page links are updated for you as part of the cloning process.</p>
		
			#html.hiddenField(name="contentID")#
			#html.textfield(name="title", label="Please enter the new page title:", class="input-block-level", required="required", size="50",wrapper="div class=controls",labelClass="control-label",groupWrapper="div class=control-group")#
			<label for="pageStatus">Publish all pages in hierarchy?</label>
			<small>By default all cloned pages are published as drafts.</small><br>
			#html.select(options="true,false", name="pageStatus", selectedValue="false", class="input-block-level",wrapper="div class=controls",labelClass="control-label",groupWrapper="div class=control-group")#
			
			<!---Notice --->
			<div class="alert alert-info">
				<i class="icon-info-sign icon-large"></i> Please note that cloning is an expensive process, so please be patient when cloning big hierarchical content trees.
			</div>
		</div>
        <div class="modal-footer">
            <!--- Button Bar --->
        	<div id="cloneButtonBar">
          		<button class="btn" id="closeButton"> Cancel </button>
          		<button class="btn btn-danger" id="cloneButton"> Clone </button>
            </div>
			<!--- Loader --->
			<div class="center loaders" id="clonerBarLoader">
				<i class="icon-spinner icon-spin icon-large icon-2x"></i>
				<br>Please wait, doing some hardcore cloning action...
			</div>
        </div>
		#html.endForm()#
	</div>
</div>
</cfif>
<cfif prc.oAuthor.checkPermission("PAGES_ADMIN")>
<div id="importDialog" class="modal hide fade">
	<div id="modalContent">
	    <div class="modal-header">
	        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
	        <h3><i class="icon-copy"></i> Import Pages</h3>
	    </div>
        #html.startForm(name="importForm", action=prc.xehPageImport, class="form-vertical", multipart=true)#
        <div class="modal-body">
			<p>Choose the ContentBox <strong>JSON</strong> pages file to import. The creator of the page is matched via their <strong>username</strong> and 
			page overrides are matched via their <strong>slug</strong>.
			If the importer cannot find the username from the import file in your installation, then it will ignore the record.</p>
			
			#html.fileField(name="importFile", required=true, wrapper="div class=controls")#
			
			<label for="overrideContent">Override blog entries?</label>
			<small>By default all content that exist is not overwritten.</small><br>
			#html.select(options="true,false", name="overrideContent", selectedValue="false", class="input-block-level",wrapper="div class=controls",labelClass="control-label",groupWrapper="div class=control-group")#
			
			<!---Notice --->
			<div class="alert alert-info">
				<i class="icon-info-sign icon-large"></i> Please note that import is an expensive process, so please be patient when importing.
			</div>
		</div>
        <div class="modal-footer">
            <!--- Button Bar --->
        	<div id="importButtonBar">
          		<button class="btn" id="closeButton"> Cancel </button>
          		<button class="btn btn-danger" id="importButton"> Import </button>
            </div>
			<!--- Loader --->
			<div class="center loaders" id="importBarLoader">
				<i class="icon-spinner icon-spin icon-large icon-2x"></i>
				<br>Please wait, doing some hardcore importing action...
			</div>
        </div>
		#html.endForm()#
	</div>
</div>
</cfif>
</cfoutput>