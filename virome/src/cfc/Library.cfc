<cfcomponent displayname="Library" output="false" hint="
			This componented is used to get everything Library related information.  
			It is used to gather, format and return all information in reference to Library.
			Functions within this component are used directly by Flex and as helper
			function by other components
			">

	<cffunction name="getLibrary" access="remote" returntype="query" hint="
				Get all metadata in refernece to a library, list of libraries or all libraries in an environment
				This function acts as a helper functions to ther ColdFusion components such as OrfRPC, ReadRPC, SearchRPC and StatisticsRPC.
				This function be called directly from Flex view to display library information in browse, search and statistics view.  
				
				Return: A hash of libray metadata
				">
				
		<cfargument name="id" default="-1" type="Numeric" hint="Library ID">
		<cfargument name="libraryIdList" default="" type="string" hint="Comma separated list of library IDs">
		<cfargument name="publish" default="-1" type="Numeric" hint="Flag to get library information for public/private or both type of libraries ">
		<cfargument name="environment" default="" type="String" hint="Environment name">
		
		<!---<cfargument name="privateOnly" default="False" type="boolean">--->
				
		<cftry>
			<cfset q="">
			<!--- <cfquery name="q" datasource="#request.mainDSN#">
				SELECT	l.id,
						lower(l.name) as name,
						l.description,
						lower(l.environment) as environment,
						l.prefix,
						l.server,
						l.publish,
						l.groupId,
						l.project,
						ls.citation,
						ls.citation_pdf,
						ls.seq_type,
						ls.lib_type,
						ls.na_type,
						ls.geog_place_name,
						ls.country,
						ls.amplification,
						ls.filter_lower_um,
						ls.filter_upper_um,
						ls.sample_date,
						ls.lat_deg,
						ls.lon_deg,
						ls.lat_hem,
						ls.lon_hem,
						ls.country
				FROM	library l
					INNER JOIN
						lib_summary ls on l.id = ls.libraryId
				WHERE	l.deleted = 0 and l.progress="complete"
					<cfif arguments.id gt -1>
						and l.id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
					</cfif>
					<cfif arguments.publish gt -1>
						and l.publish = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.publish#">
					</cfif>
					<cfif len(arguments.libraryIdList) gt 0>
						and l.id in (#arguments.libraryIdList#)
						and l.publish = 0
					</cfif>
					<cfif len(arguments.environment)>
						and l.environment = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.environment#">
					</cfif>
				order by l.environment, l.prefix, l.name, l.description asc, l.publish desc
			</cfquery> --->
			
			<cfquery name="q" datasource="#request.mainDSN#">
				SELECT	l.id,
						lower(l.name) as name,
						l.description,
						lower(l.environment) as environment,
						l.prefix,
						l.server,
						l.publish,
						l.groupId,
						l.project,
						ls.citation,
						"" as citation_pdf,
						ls.seqmethod as seq_type,
						ls.metatype as lib_type,
						ls.acidtype as na_type,
						ls.place as geog_place_name,
						ls.country,
						ls.amplification,
						ls.filter_lowerbound as filter_lower_um,
						ls.filter_upperbound as filter_upper_um,
						ls.sampdate as sample_date,
						ls.latitude as lat_deg,
						ls.longitude as lon_deg,
						ls.latitude as lat_hem,
						ls.latitude as lon_hem
				FROM	library l
					INNER JOIN
						library_metadata ls on l.id = ls.libraryId
				WHERE	l.deleted = 0 and l.progress="complete"
					<cfif arguments.id gt -1>
						and l.id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
					</cfif>
					<cfif arguments.publish gt -1>
						and l.publish = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.publish#">
					</cfif>
					<cfif len(arguments.libraryIdList) gt 0>
						and l.id in (#arguments.libraryIdList#)
						and l.publish = 0
					</cfif>
					<cfif len(arguments.environment)>
						and l.environment = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.environment#">
					</cfif>
				order by l.environment, l.prefix, l.name, l.description asc, l.publish desc
			</cfquery>
			
			<cfcatch type="any">
				<cfset CreateObject("component",  request.cfc & ".Utility").reporterror(method_name="Library", 
																						function_name=getFunctionCalledName(), 
																						args=arguments, 
																						msg=cfcatch.Message, 
																						detail=cfcatch.Detail,
																						tagcontent=cfcatch.tagcontext)>
			</cfcatch>
			
			<cffinally>
				<cfreturn q/>
			</cffinally>
		</cftry>
	</cffunction>
	
	<cffunction name="getSequenceSizeOrGC" access="private" returntype="Query" hint="
				Get length of reads/contig sequence in nucleotide or length of ORFs in amino acid or GC value of all sequences in a give library
				A helper function for 
					getHistogram()
				
				Return: A strucutre of GC value or sequence size per sequence.
				">
				
		<cfargument name="libraryId" type="numeric" required="true" hint="Library ID">
		<cfargument name="server" type="string" required="true" hint="Server/Database name to look for sequences in">
		<cfargument name="type" type="numeric" required="true" hint="Flag indicating weather to retrieve read/contig sequence or ORF sequences">
		
		<cfset q=""/>
		<cftry>
			<cfquery name="q" datasource="#arguments.server#" result="sequenceSizeOrGCQuery">
				SELECT	(<cfif arguments.type eq 0>
							gc
						<cfelseif arguments.type eq 1>
							s.size
						<cfelse>
							s.size*3
						</cfif>) as hval
				FROM	sequence s
					inner join 
						sequence_relationship sr on s.id = sr.objectId
				WHERE	s.libraryId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.libraryId#"/>
					<cfif arguments.type eq 0>
						and sr.typeId = 1
					<cfelse>
						and sr.typeId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.type#"/>
					</cfif>					
				ORDER BY hval desc
			</cfquery>
			
			<cfcatch type="any">
				<cfset CreateObject("component",  request.cfc & ".Utility").reporterror(method_name="Library", 
																						function_name=getFunctionCalledName(), 
																						args=arguments, 
																						msg=cfcatch.Message, 
																						detail=cfcatch.Detail,
																						tagcontent=cfcatch.tagcontext)>
			</cfcatch>
			
			<cffinally>
				<cfreturn q/>
			</cffinally>
		</cftry>
	</cffunction>
	
		
	<cffunction name="getEnvironment" access="private" returntype="query" hint="
				Get environment name for give library(ies)
				A helper function for 
					getEnvironmentObject()
				 
				Return: A hash of evironment name for each library
				">
		<cfargument name="libraryIdList" type="string" default="" hint="Comma separated list of library IDs"/>
		
		<cftry>
			<cfset q = "" />
			
			<cfquery name="q" datasource="#request.mainDSN#">
				SELECT 	distinct environment
				FROM	library
				WHERE	deleted = 0
					<cfif len(arguments.libraryIdList)>
						and id in (#arguments.libraryIdList#)
					</cfif>
			</cfquery>
			
			<cfcatch type="any">
				<cfset CreateObject("component",  request.cfc & ".Utility").reporterror(method_name="Library", 
																						function_name=getFunctionCalledName(), 
																						args=arguments, 
																						msg=cfcatch.Message, 
																						detail=cfcatch.Detail,
																						tagcontent=cfcatch.tagcontext)>
			</cfcatch>
			
			<cffinally>
				<cfreturn q/>
			</cffinally>
		</cftry>
	</cffunction>
	
	<cffunction name="jsonHelper" access="private" returntype="void" hint="
				Create a JSON object of a given hash and write it to a file. 
				This make it easy to read and format data for constant repeated requested data.
				A helper function for 
					getTaxAtLevel()
					setReadObject()
					setORFTypeObject()
					setVIROMECatObject() and 
					getServerOverview()
					
				Return: NA" >
				
		<cfargument name="struct" type="Struct" required="true" hint="A hash of data to be written in JSON format">
		<cfargument name="filename" type="String" required="true" hint="Filename to write JSON object">
		
		<cftry>
			<cfscript>
				djson = StructNew();
				djson = arguments.struct;
				
				if (FileExists(#arguments.filename#)){
					data = FileRead(#arguments.filename#);
					
					if(len(data)){
						djson = deserializeJSON(data);
						StructAppend(djson,arguments.struct);
					}
				}
				
				myfile = FileOpen(#arguments.filename#,"write","UTF-8");
				sjson = SerializeJSON(djson);
				FileWriteLine(myfile,sjson);
				FileClose(myfile);
			</cfscript>
			
			<cfcatch type="any">
				<cfset CreateObject("component",  request.cfc & ".Utility").reporterror(method_name="Library", 
																						function_name=getFunctionCalledName(), 
																						args=arguments, 
																						msg=cfcatch.Message, 
																						detail=cfcatch.Detail,
																						tagcontent=cfcatch.tagcontext)>
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="getTaxAtLevel" access="private" returntype="void" hint="
				Get domain level taxonomy breakdown for a give library
				A helper function for: 
					getStatistics()
					
				Return: NA (write data to JSON object realted to the library)
				">
		<cfargument name="libraryId" type="Numeric" required="true" />
		<cfargument name="server" type="String" required="true" />
		<cfargument name="environment" type="String" default="" />
		<cfargument name="filename" type="string" default=""/>

		<cfset objarr = ArrayNew(1)>
		
		<cftry>
			<cfquery name="qry" datasource="#arguments.server#">
				SELECT	lineage,
						libraryId
				FROM	statistics
				WHERE	deleted = 0 
					and	libraryId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.libraryId#"/>		
			</cfquery>
			<cfset str = ""/>
			
			<cfif qry.recordcount>
				<!--- parse the lineage from statistics table and create a struct --->
				<cfloop list="#qry.lineage#" index="level" delimiters=";">
						<cfset tmp = ListToArray(level,":")/>
						<cfset obj = StructNew()>
						<cfset StructInsert(obj,"type",#iif(len(tmp[1]), "tmp[1]", """Unclassified""")#)>
						<cfset StructInsert(obj,"count",tmp[2])>
						<cfset StructInsert(obj,"library",arguments.libraryId)>
						<cfset StructInsert(obj,"environment",arguments.environment)>
						<cfset StructInsert(Obj,"database","UNIREF100P")>
						<cfset ArrayAppend(objarr,obj)>
				</cfloop>
			
				<cfscript>
					struct = structnew();
					StructInsert(struct,"DOMAIN",objarr);
					
					jsonHelper(struct,arguments.filename);
				</cfscript>
			</cfif>
			
			<cfcatch type="any">
				<cfset CreateObject("component",  request.cfc & ".Utility").reporterror(method_name="Library", 
																						function_name=getFunctionCalledName(), 
																						args=arguments, 
																						msg=cfcatch.Message, 
																						detail=cfcatch.Detail,
																						tagcontent=cfcatch.tagcontext)>
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="setReadObject" access="private" returntype="void" hint="
				Generate detail read/contig level metadata for give library. All data is saved/appened to overall JSON object
				A helper function for:
					getStatistics()
			
				Return: NA (write data to JSON object realted to the library)
				">
		<cfargument name="libraryId" type="numeric" required="true">
		<cfargument name="server" type="string" required="true" >
		<cfargument name="environment" type="string" required="true" >
		<cfargument name="filename" type="string" required="true">
		
		<cftry>
			<cfquery name="qry" datasource="#arguments.server#">
				SELECT	read_cnt,
						read_mb
				FROM	statistics
				WHERE	deleted = 0 
					and	libraryId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.libraryId#"/>
			</cfquery>
			
			<cfscript>
				if (qry.RecordCount){
					obj = StructNew();
					objarr = ArrayNew(1);
					
					StructInsert(obj,"type","read");
					StructInsert(obj,"count",qry.read_cnt);
					StructInsert(obj,"mbp",qry.read_mb);
					StructInsert(obj,"library",arguments.libraryId);
					StructInsert(obj,"environment",arguments.environment);
					
					ArrayAppend(objarr,obj);
					
					struct = structnew();
					StructInsert(struct,"READ",objarr);
					
					jsonHelper(struct,arguments.filename);
				}
			</cfscript>
			
			<cfcatch type="any">
				<cfset CreateObject("component",  request.cfc & ".Utility").reporterror(method_name="Library", 
																						function_name=getFunctionCalledName(), 
																						args=arguments, 
																						msg=cfcatch.Message, 
																						detail=cfcatch.Detail,
																						tagcontent=cfcatch.tagcontext)>
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="setORFTypeObject" access="private" returntype="void" hint="
				Generate detail ORF level metadata for give library. All data is saved/appened to overall JSON object
				A helper function for:
					getStatistics()
			
				Return: NA (write data to JSON object realted to the library)
				">
				
		<cfargument name="libraryId" type="numeric" required="true" hint="Library ID">
		<cfargument name="server" type="string" required="true" hint="Server name (database name)">
		<cfargument name="environment" type="string" required="true" hint="Environment name">
		<cfargument name="filename" type="string" required="true" hint="Filename where JSON information is stored">
		
		<cftry>
			<cfquery name="qry" datasource="#arguments.server#">
				SELECT	complete_cnt, complete_mb,
						incomplete_cnt, incomplete_mb,
						lackstart_cnt, lackstart_mb,
						lackstop_cnt, lackstop_mb,
						libraryId
				FROM	statistics
				WHERE	deleted = 0 
					and	libraryId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.libraryId#"/>		
			</cfquery>
			
			<cfscript>
				if (qry.RecordCount){
					obj = StructNew();
					objarr = ArrayNew(1);
					
					StructInsert(obj,"type","complete");
					StructInsert(obj,"count",qry.complete_cnt);
					StructInsert(obj,"mbp",qry.complete_mb);
					StructInsert(obj,"library",arguments.libraryId);
					StructInsert(obj,"environment",arguments.environment);
					ArrayAppend(objarr,obj);
					
					obj=StructNew();
					StructInsert(obj,"type","lack both ends");
					StructInsert(obj,"count",qry.incomplete_cnt);
					StructInsert(obj,"mbp",qry.incomplete_mb);
					StructInsert(obj,"library",arguments.libraryId);
					StructInsert(obj,"environment",arguments.environment);
					ArrayAppend(objarr,obj);
					
					obj=StructNew();
					StructInsert(obj,"type","lack start");
					StructInsert(obj,"count",qry.lackstart_cnt);
					StructInsert(obj,"mbp",qry.lackstart_mb);
					StructInsert(obj,"library",arguments.libraryId);
					StructInsert(obj,"environment",arguments.environment);
					ArrayAppend(objarr,obj);
					
					obj=StructNew();
					StructInsert(obj,"type","lack stop");
					StructInsert(obj,"count",qry.lackstop_cnt);
					StructInsert(obj,"mbp",qry.lackstop_mb);
					StructInsert(obj,"library",arguments.libraryId);
					StructInsert(obj,"environment",arguments.environment);
					ArrayAppend(objarr,obj);
					
					struct = StructNew();
					StructInsert(struct,"ORFTYPE",objarr);
					
					jsonHelper(struct,arguments.filename);	
				}
			</cfscript>
			
			<cfcatch type="any">
				<cfset CreateObject("component",  request.cfc & ".Utility").reporterror(method_name="Library", 
																						function_name=getFunctionCalledName(), 
																						args=arguments, 
																						msg=cfcatch.Message, 
																						detail=cfcatch.Detail,
																						tagcontent=cfcatch.tagcontext)>
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="setVIROMECatObject" access="private" returntype="void" hint="
				Generate detail VIROME category information such as 
					no. of tRNA
					no. of rRNA
					no. of ORFans
					no. of functional orfs
					no. of viral orfs etc...
				
				for give library. All data is saved/appened to overall JSON object
				A helper function for:
					getStatistics()
			
				Return: NA (write data to JSON object realted to the library)
				">

		<cfargument name="libraryId" type="numeric" required="true" hint="Library Id">
		<cfargument name="server" type="string" required="true" hint="Server name (database name)">
		<cfargument name="environment" type="string" required="true" hint="Environment name">
		<cfargument name="filename" type="string" required="true" hint="Filename where JSON information is stored">

		<cftry>
			<cfquery name="qry" datasource="#arguments.server#">
				SELECT	tRNA_cnt, tRNA_id, 
						rRNA_cnt, rRNA_id,
						orfan_cnt, orfan_id,
						topviral_cnt, topviral_id,
						allviral_cnt, allviral_id,
						topmicrobial_cnt, topmicrobial_id,
						allmicrobial_cnt, allmicrobial_id,
						fxn_cnt, fxn_id,
						unassignfxn_cnt, unassignfxn_id,
						libraryId
				FROM	statistics
				WHERE	deleted = 0 
					and	libraryId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.libraryId#"/>
			</cfquery>
			
			<cfscript>
				if (qry.RecordCount){
					obj = StructNew();
					objarr = ArrayNew(1);
					
					StructInsert(obj,"type","tRNA");
					StructInsert(obj,"count",qry.tRNA_cnt);
					StructInsert(obj,"library",arguments.libraryId);
					StructInsert(obj,"environment",arguments.environment);
					ArrayAppend(objarr,obj);
										
					obj=StructNew();
					StructInsert(obj,"type","rRNA");
					StructInsert(obj,"count",qry.rRNA_cnt);
					StructInsert(obj,"library",arguments.libraryId);
					StructInsert(obj,"environment",arguments.environment);
					ArrayAppend(objarr,obj);
					
					obj=StructNew();
					StructInsert(obj,"type","ORFans");
					StructInsert(obj,"count",qry.orfan_cnt);
					StructInsert(obj,"library",arguments.libraryId);
					StructInsert(obj,"environment",arguments.environment);
					ArrayAppend(objarr,obj);
					
					obj=StructNew();
					StructInsert(obj,"type","Top viral hit");
					StructInsert(obj,"count",qry.topviral_cnt);
					StructInsert(obj,"library",arguments.libraryId);
					StructInsert(obj,"environment",arguments.environment);
					StructInsert(obj,"database","METAGENOMES");
					ArrayAppend(objarr,obj);
					
					obj=StructNew();
					StructInsert(obj,"type","Only viral hit");
					StructInsert(obj,"count",qry.allviral_cnt);
					StructInsert(obj,"library",arguments.libraryId);
					StructInsert(obj,"environment",arguments.environment);
					StructInsert(Obj,"database","METAGENOMES");
					ArrayAppend(objarr,obj);
					
					obj=StructNew();
					StructInsert(obj,"type","Top microbial hit");
					StructInsert(obj,"count",qry.topmicrobial_cnt);
					StructInsert(obj,"library",arguments.libraryId);
					StructInsert(obj,"environment",arguments.environment);
					StructInsert(Obj,"database","METAGENOMES");
					ArrayAppend(objarr,obj);
					
					obj=StructNew();
					StructInsert(obj,"type","Only microbial hit");
					StructInsert(obj,"count",qry.allmicrobial_cnt);
					StructInsert(obj,"library",arguments.libraryId);
					StructInsert(obj,"environment",arguments.environment);
					StructInsert(Obj,"database","METAGENOMES");
					ArrayAppend(objarr,obj);
					
					obj=StructNew();
					StructInsert(obj,"type","Functional protein");
					StructInsert(obj,"count",qry.fxn_cnt);
					StructInsert(obj,"library",arguments.libraryId);
					StructInsert(obj,"environment",arguments.environment);
					StructInsert(Obj,"database","UNIREF100P");
					ArrayAppend(objarr,obj);
					
					obj=StructNew();
					StructInsert(obj,"type","Unassigned protein");
					StructInsert(obj,"count",qry.unassignfxn_cnt);
					StructInsert(obj,"library",arguments.libraryId);
					StructInsert(obj,"environment",arguments.environment);
					StructInsert(Obj,"database","UNIREF100P");
					ArrayAppend(objarr,obj);

					struct = StructNew();
					StructInsert(struct,"VIRCAT",objarr);
					
					jsonHelper(struct,arguments.filename);	
				}
			</cfscript>
			
			<cfcatch type="any">
				<cfset CreateObject("component",  request.cfc & ".Utility").reporterror(method_name="Library", 
																						function_name=getFunctionCalledName(), 
																						args=arguments, 
																						msg=cfcatch.Message, 
																						detail=cfcatch.Detail,
																						tagcontent=cfcatch.tagcontext)>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getStatistics" access="private" returntype="struct" hint="
				Generate detail statistics information such as  
					read details
					ORF details
					virome category details and
					domain level taxonomy information 
				for give library.
				A helper function for:
					getLibraryInfo()
			
				Return: A hash of library details
				">
				
		<cfargument name="id" type="Numeric" required="true" hint="Library ID"/>
		<cfargument name="server" type="String" required="true" hint="Server (database) name"/>
		<cfargument name="environment" type="String" default="" hint="Environment name"/>
		
		<cfset stat_struct = StructNew()>
		<cfset local.filename = "LIBRARY_STAT_" & arguments.id & ".json"/>
		
		<cftry>
			<cfif NOT FileExists(request.xDocsFilePath&"/"&#local.filename#)>
				<cfscript>
					setReadObject(libraryId=arguments.id,server=arguments.server,environment=arguments.environment,filename=request.xDocsFilePath&"/"&#local.filename#);
					
					setORFTypeObject(libraryId=arguments.id,server=arguments.server,environment=arguments.environment,filename=request.xDocsFilePath&"/"&#local.filename#);
					
					setVIROMECatObject(libraryId=arguments.id,server=arguments.server,environment=arguments.environment,filename=request.xDocsFilePath&"/"&#local.filename#);
					
					getTaxAtLevel(libraryId=arguments.id,server=arguments.server,environment=arguments.environment,filename=request.xDocsFilePath&"/"&#local.filename#);
				</cfscript>
			</cfif>
			
			<cfscript>
				//check if there was any data for a given lib.
				if (not FileExists(request.xDocsFilePath&"/"&#local.filename#)){
					writelog(text="return empty",type="information",file="virome");
					return stat_struct;
				}

				data = FileRead(request.xDocsFilePath&"/"&#local.filename#);
				
				if(not isNull(data))
					stat_struct = deserializeJSON(data);
			</cfscript>
			
			<cfcatch type="any">
				<cfset CreateObject("component",  request.cfc & ".Utility").reporterror(method_name="Library", 
																						function_name=getFunctionCalledName(), 
																						args=arguments, 
																						msg=cfcatch.Message, 
																						detail=cfcatch.Detail,
																						tagcontent=cfcatch.tagcontext)>
			</cfcatch>
			
			<cffinally>
				<cfreturn stat_struct/>
			</cffinally>
		</cftry>
	</cffunction>

	<cffunction name="serverOverviewHelper" access="private" returntype="Struct" hint="
				Generate detail overview of environmental information such as
					read count
					ORF count
					total number of read megabases
					total number of ORF megabases
				
				A helper function for
					getServerOverview()
				
				Return: hash of environmental details
				">
				
		<cfargument name="environment" type="string" required="true" hint="Environment name">
		<cfargument name="libraryId" type="string" required="true" hint="Library ID">
		
		<cftry>
			<cfset serverObj = CreateObject("component", request.cfc & ".Utility").getServerName(environment=arguments.environment)/>
			<cfset _server = serverObj.server/>
			
			<!--- get total library, read and orf counts, plus total read and orf size --->
			<cfquery name="qry" datasource="#_server#">
				SELECT	count(libraryId) as no_libs,
						SUM(read_cnt) as no_reads,
						SUM(read_mb) as read_mb,
						SUM(complete_cnt+incomplete_cnt+lackstart_cnt+lackstop_cnt) as no_orfs,
						SUM(complete_mb+incomplete_mb+lackstart_mb+lackstop_mb) as orf_mb
				FROM 	statistics
				WHERE	libraryId in (#arguments.libraryId#)
					and deleted = 0
			</cfquery>
			
			<cflog type="information" text="environment: #arguments.environment# ... count: #qry.RecordCount#" file="virome.library" > 
					
			<cfcatch type="any">
				<cfset CreateObject("component",  request.cfc & ".Utility").reporterror(method_name="Library", 
																						function_name=getFunctionCalledName(), 
																						args=arguments, 
																						msg=cfcatch.Message, 
																						detail=cfcatch.Detail,
																						tagcontent=cfcatch.tagcontext)>
			</cfcatch>
			
			<cffinally>		
				<cfreturn CreateObject("component", request.cfc & ".Utility").QueryToStruct(Query=qry, Row=1)/>
			</cffinally>
		</cftry>
	</cffunction>
	
	<cffunction name="getMeanSTD" access="private" returntype="Struct" hint="
				Get mean sequence length and standard deviation  
				
				Return: A hash of mean sequence length and standard deviation
				">
				
		<cfargument name="libraryId" type="numeric" required="true" hint="Library ID"/>
		<cfargument name="server" type="string" required="true" hint="Server (database) name"/>
		<cfargument name="typeId" type="numeric" required="true" hint="Flag indicating read or ORF"/>
	
		<cfset lstr = structnew()/>
		<cftry>
			<cfset count = 0/>
			<cfset xBar = 0/>
			<cfset std_dev = 0/>
			<cfset sumXBar = 0/>
			<cfset sum = 0/>
			
			<cfquery name="q" datasource="#arguments.server#">
				SELECT	s.size
				FROM	sequence s
				WHERE	s.libraryId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.libraryId#"/>
					and s.typeId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.typeId#"/>
			</cfquery>
			
			<cfset count = q.RecordCount/>
			
			<cfloop query="q" >
				<cfset sum += q.size/> 
			</cfloop>
			
			<cfset xBar = (sum/count) >
			
			<cfloop query="q" >
				<cfset sumXBar += ((q.size - xBar)*(q.size - xBar)) /> 
			</cfloop>
			
			<cfset std_dev = sqr(sumXBar/count)/>
			
			<cfset StructInsert(lstr,"MEAN", xBar) />
			<cfset StructInsert(lstr,"STDEV", std_dev) />
			
			<cfcatch type="any">
				<cfset CreateObject("component",  request.cfc & ".Utility").reporterror(method_name="Library", 
																						function_name=getFunctionCalledName(), 
																						args=arguments, 
																						msg=cfcatch.Message, 
																						detail=cfcatch.Detail,
																						tagcontent=cfcatch.tagcontext)>
			</cfcatch>
			
			<cffinally>
				<cfreturn lstr/>
			</cffinally>
		</cftry>
	</cffunction>
	
	<cffunction name="getLibraryInfo" access="remote" returntype="Struct" hint="
				Gather detail library information and metadata for library
				
				Return: hash of library information 
				">
				
		<cfargument name="environment" type="string" required="true" hint="Environment name"/>
		<cfargument name="libraryIdList" type="string" required="true" hint="Comma separated library ID list"/>
		<cfargument name="publish" type="numeric" required="true" default="1" hint="Flag to retrieve public or private library"/>
		
		<cfset struct = StructNew()>
		<cftry>
			<cfset summary = StructNew()>
			<cfset detail = StructNew()>
			<cfset arr = ArrayNew(1)>
			<cfset lib = getLibrary(environment=arguments.environment,libraryIdList=arguments.libraryIdList,publish=arguments.publish)>

			<cfif isQuery(lib)>
				<cfloop query="lib">
					<cfset StructInsert(summary,"LIBID",lib.id)>
					<cfset StructInsert(summary,"LIBNAME",lib.name)>
					<cfset StructInsert(summary,"DESCRIPTION",lib.description)>
					<cfset StructInsert(summary,"PREFIX",lib.prefix)>
					<cfset StructInsert(summary,"SERVER",lib.server)>
					<cfset StructInsert(summary,"PUBLISH",lib.publish)>
					<cfset StructInsert(summary,"PROJECT",lib.project)>
					<cfset StructInsert(summary,"CITATION",lib.citation)>
					<!---<cfset StructInsert(summary,"LINK",lib.citation_pdf)>--->
					<!--- library_metatadata table does not consist of citation_pdf --->
					<cfset StructInsert(summary, "LINK", "")>
						
					<cfset StructInsert(summary,"NA_TYPE",lib.na_type)>
					<cfset StructInsert(summary,"ENVIRONMENT",arguments.environment)>
					
					<cfset detail = getStatistics(id=lib.id,server=lib.server,environment=arguments.environment)>
					<cfset StructInsert(summary,"DETAIL",detail)>

					<cfset ArrayAppend(arr,summary)>
					<cfset summary = StructNew()>
					<cfset detail = StructNew()>
				</cfloop>

				<cfset StructInsert(struct,"environment",arguments.environment)>
				<cfset StructInsert(struct,"children",arr)>
			</cfif>

			<cfcatch type="any">
				<cfset CreateObject("component",  request.cfc & ".Utility").reporterror(method_name="Library", 
																						function_name=getFunctionCalledName(), 
																						args=arguments, 
																						msg=cfcatch.Message, 
																						detail=cfcatch.Detail,
																						tagcontent=cfcatch.tagcontext)>
			</cfcatch>
			
			<cffinally>
				<cfreturn struct/>
			</cffinally>
		</cftry>
	</cffunction>

	<cffunction name="getEnvironmentObject" access="remote" returntype="Array" hint="
				Get environment information of give list of libraries
				This function is directly called from Flex search, statistics and browse view
				
				Return: An array of hash of environment name
				">
				
		<cfargument name="libraryIdList" type="string" default="" hint="Comma separated list of library ID"/>

		<cftry>
			<cfset e = getEnvironment(libraryIdList = arguments.libraryIdList) />
			<cfset struct = StructNew()>
			<cfset array = ArrayNew(1)>
	
			<cfset type = "PUBLIC" />
			<cfif len(libraryIdList) gt 0>
				<cfset type = "PRIVATE" />
			</cfif>
	
			<cfset StructInsert(struct,"label", "Select One")>
			<cfset StructInsert(struct,"data", "-1")>
			<cfset ArrayAppend(array, struct)>
	
			<cfloop query="e">
				<cfscript>
					struct = StructNew();
					structInsert(struct, "label", "#UCase(q.environment)#");
					structInsert(struct, "data", "#UCase(q.environment)#");
					structInsert(struct, "type", "#type#");
	
					ArrayAppend(array, struct);
				</cfscript>
			</cfloop>

			<cfcatch type="any">
				<cfset CreateObject("component",  request.cfc & ".Utility").reporterror(method_name="Library", 
																						function_name=getFunctionCalledName(), 
																						args=arguments, 
																						msg=cfcatch.Message, 
																						detail=cfcatch.Detail,
																						tagcontent=cfcatch.tagcontext)>
			</cfcatch>
			
			<cffinally>
				<cfreturn array />
			</cffinally>
		</cftry>			
	</cffunction>

	<cffunction name="getLibraryObject" access="remote" returntype="Array" hint="
				Get library ID and name.
				This Function is called directly by flex views such as search, statistics and browse view
				
				Return: An array of strucutre of library name and id
				">
		<cfargument name="environment" type="string" required="true">
		<cfargument name="libraryIdList" type="string" required="true"/>
		
		<cftry>
			<cfset libList = "">
			<cfset struct = StructNew()>
			<cfset array = ArrayNew(1)>
	
			<cfset StructInsert(struct, "label", "Select One")>
			<cfset StructInsert(struct, "data", "-1")>
			<cfset ArrayAppend(array, struct)>
			
			<cfset pub_lib = getLibrary(environment=arguments.environment, publish=1)>
			<cfloop query="pub_lib">
				<cfscript>
					struct = StructNew();
					structInsert(struct, "label", "Public: " & #UCase(pub_lib.name)#);
					structInsert(struct, "data", "#pub_lib.id#");
					ArrayAppend(array, struct);
				</cfscript>
			</cfloop>
			
			<cfif len(libraryIdList) gt 0>
				<cfset pri_lib = getLibrary(environment=arguments.environment, libraryIdList=arguments.libraryIdList, publish=0)>
				<cfloop query="pri_lib">
					<cfscript>
						struct = StructNew();
						structInsert(struct, "label", "Private: " & #UCase(pri_lib.name)#);
						structInsert(struct, "data", "#pri_lib.id#");
						ArrayAppend(array, struct);
					</cfscript>
				</cfloop>
			</cfif>
			
			<cfcatch type="any">
				<cfset CreateObject("component",  request.cfc & ".Utility").reporterror(method_name="Library", 
																						function_name=getFunctionCalledName(), 
																						args=arguments, 
																						msg=cfcatch.Message, 
																						detail=cfcatch.Detail,
																						tagcontent=cfcatch.tagcontext)>
			</cfcatch>
			
			<cffinally>
				<cfreturn array />
			</cffinally>
		</cftry>			
	</cffunction>
	
	<cffunction name="getAllLibrary" access="remote" returntype="Array" hint="
				Gather all library and environment information
				
				Return: An array of hash of library name, environment and library ID
				">
				
		<cfargument name="libraryIdList" type="string" default="" hint="Comma seperated list of library ID"/>
		
		<cftry>
			<cfset arr = ArrayNew(1)/>
			
			<cfset pub_lib = getLibrary(publish=1) />
			
			<cfloop query="pub_lib">
				<cfscript>
					var struct = StructNew();
					structInsert(struct, "label", #ucase(pub_lib.environment)# & ": " & #ucase(pub_lib.name)#);
					structInsert(struct, "env", #lcase(pub_lib.environment)#);
					structInsert(struct, "data", #pub_lib.id#);
					ArrayAppend(arr, struct);
				</cfscript>
			</cfloop>
			
			<cfif listLen(arguments.libraryIdList)>
				<cfset priv_lib = getLibrary(libraryIdList=arguments.libraryIdList)>
				
				<cfloop query="priv_lib">
					<cfscript>
						var struct = StructNew();
						structInsert(struct, "label", #ucase(priv_lib.environment)# & ": " & #ucase(priv_lib.name)#);
						structInsert(struct, "env", #lcase(priv_lib.environment)#);
						structInsert(struct, "data", #priv_lib.id#);
						ArrayAppend(arr, struct);
					</cfscript>
				</cfloop>
			</cfif>
			
			<cfset arr = CreateObject("component", request.cfc & ".Utility").SortArrayOfStrut(arr, "env")/>
			
			<cfcatch type="any">
				<cfset CreateObject("component",  request.cfc & ".Utility").reporterror(method_name="Library", 
																						function_name=getFunctionCalledName(), 
																						args=arguments, 
																						msg=cfcatch.Message, 
																						detail=cfcatch.Detail,
																						tagcontent=cfcatch.tagcontext)>
			</cfcatch>
			
			<cffinally>
				<cfreturn arr/>
			</cffinally>
		</cftry>
	</cffunction>
	
	<cffunction name="getBLASTDBObject" access="remote" returntype="Array" hint="
				Gather all BLASTable libraries and their respective metadata
				This function is used 
				
				Return: An array of hash of BLASTable database 
				">
		<cfargument name="libraryIdList" type="string" default=""/>
		
		<cfset struct = StructNew()/>
		<cfset arr = ArrayNew(1)/>
		
		<cftry>
			<cfset lib = getLibrary(publish=1)/>
			
			<cfif listLen(arguments.libraryIdList)>
				<cfset priv_lib = getLibrary(libraryIdList=arguments.libraryIdList)>
				
				<cfloop query="priv_lib" >
					<cfset priv_lib.name = "Private: " & priv_lib.name/> 
				</cfloop>
				
				<cfquery name="all" dbtype="query" >
					SELECT * FROM lib
					UNION
					SELECT * FROM priv_lib
					ORDER BY environment, description asc, publish desc
				</cfquery>
			<cfelse>
				<cfset all = lib/>
			</cfif>
			
			<cfset evn_idx = 0/>
			
			<cfoutput query="all" group="environment">
				<cfset struct = StructNew()/>
				<cfset env_libs = ""/>
				
				<cfset struct['label'] = UCase(all.environment) & " ENVIRONMENT" />
				<cfset struct['data'] = UCase(REReplace(all.environment, "_| ", "-", "ALL")) />
				<cfset ArrayAppend(arr, struct) />
				
				<cfset env_idx = arraylen(arr)/>
				
				<cfoutput group="description">
					<cfset struct = StructNew()/>
					<cfset struct['label'] = "     "&UCase(all.name)/>
					<cfset struct['data'] = lcase(listFirst(all.environment, " ")) & "/" & UCase(all.prefix)/>
					
					<cfset env_libs &= lcase(listFirst(all.environment, " ")) & "/" & UCase(all.prefix) & ","/>
					<cfset ArrayAppend(arr, struct)/>
				</cfoutput>
				
				<cfset env_libs = ReReplace(env_libs, ",$", "", "one")/>
				<cfset arr[env_idx]['data'] = env_libs/>
			</cfoutput>
			
			<cfcatch type="any">
				<cfset CreateObject("component", request.cfc & ".Utility").reporterror(method_name="Library", 
																						function_name=getFunctionCalledName(), 
																						args=arguments, 
																						msg=cfcatch.Message, 
																						detail=cfcatch.Detail,
																						tagcontent=cfcatch.tagcontext)>
			</cfcatch>
			
			<cffinally>
				<cfreturn arr/>
			</cffinally>
		</cftry>
	</cffunction>
	
	<cffunction name="getGeneralObject" access="remote" returntype="Struct" hint="
				Collect overall detail information for a library such as
					name,
					description,
					geographical location,
					citation,
					statistics,
					mean library size,
					etc... 
				
				Function called directly from Flex applicaiton by statistics view and browse view
				
				Return: A hash of library details 
				">
		<cfargument name="obj" type="Struct" required="true" />
		
		<cfset summary=StructNew()>
		<cftry>
			<cfset lib=getLibrary(id=arguments.obj.LIBRARY)/>
			
			<cfloop query="lib">
				<cfset StructInsert(summary,"LIBID",lib.id)>
				<cfset StructInsert(summary,"PROJECT",lib.project)>
				<cfset StructInsert(summary,"ENVIRONMENT",arguments.obj.ENVIRONMENT)>
				<cfset StructInsert(summary,"DESCRIPTION",lib.description)>
				<cfset StructInsert(summary,"LIBNAME",lib.name)>
				<cfset StructInsert(summary,"PREFIX",lib.prefix)>
				<cfset StructInsert(summary,"SERVER",lib.server)>
				<cfset StructInsert(summary,"PUBLISH",lib.publish)>
				<cfset StructInsert(summary,"LIBTYPE",lib.lib_type)>
				<cfset StructInsert(summary,"CITATION",lib.citation)>
				
				<!---<cfset StructInsert(summary,"LINK",lib.citation_pdf)>--->
				<!--- library_metadata table does not have citation_pdf field --->
				<cfset StructInsert(summary, "LINK", "")>
				
				<cfset StructInsert(summary,"SAMPLEDATE",lib.sample_date)>
				<cfset StructInsert(summary,"LOCATION",lib.geog_place_name)>
				<cfset StructInsert(summary,"COUNTRY",lib.country)>
				
				<cfset StructInsert(summary,"LAT",lib.lat_deg)>
				<cfset StructInsert(summary,"LATHEM",lib.lat_hem)>
				<cfset StructInsert(summary,"LON",lib.lon_deg)>
				<cfset StructInsert(summary,"LONHEM",lib.lon_hem)>
				
				<cfset StructInsert(summary,"SEQTYPE",lib.seq_type)>
				<cfset StructInsert(summary,"AMPLIFICATION", lib.amplification)>
				<cfset StructInsert(summary,"FILTER_LOWER", lib.filter_lower_um)>
				<cfset StructInsert(summary,"FILTER_UPPER", lib.filter_upper_um)>
				
				<cfset detail = getStatistics(id=arguments.obj.LIBRARY,server=lib.server,environment=arguments.obj.ENVIRONMENT)>
				<cfset StructInsert(summary,"DETAIL",detail)>
				
				<cfset rmean = getMeanSTD(libraryId=arguments.obj.LIBRARY, server=lib.server, typeId=1)/>
				<cfset omean = getMeanSTD(libraryId=arguments.obj.LIBRARY, server=lib.server, typeId=3)/>
				
				<cfset StructInsert(summary,"RMEAN",rmean.MEAN)/>
				<cfset StructInsert(summary,"RSTDEV",rmean.STDEV)/>
				<cfset StructInsert(summary,"OMEAN",omean.MEAN)/>
				<cfset StructInsert(summary,"OSTDEV",omean.STDEV)/>
			</cfloop>
			
			<cfcatch type="any">
				<cfset CreateObject("component",  request.cfc & ".Utility").reporterror(method_name="Library", 
																						function_name=getFunctionCalledName(), 
																						args=arguments, 
																						msg=cfcatch.Message, 
																						detail=cfcatch.Detail,
																						tagcontent=cfcatch.tagcontext)>
			</cfcatch>
			
			<cffinally>
				<cfreturn summary/>
			</cffinally>
		</cftry>
	</cffunction>
	
	<cffunction name="getHistogram" access="remote" returntype="xml" hint="
				Generate xml document of GC and sequence length histogram data
				Since GC content of a library and sequence length wont change, these xml files are
				created once and save to be recalled at later time
				
				This function is called directly from Flex statistcs view.
				
				Return: Well formatted xml document 
				">
		
		<cfargument name="libraryId" type="numeric" required="true" hint="Library ID"/>
		<cfargument name="server" type="string" required="true" hint="Server (database) name"/>
		<cfargument name="type" type="numeric" required="true" hint="Flag indicating read/contig or ORF data"/>

		<cftry>
			<cfscript>
				k = 10;
				xroot = XMLNew();
				xroot.xmlRoot = XMLElemNew(xroot,"root");
				root = xroot.xmlRoot;	
				
				//set file name to GC/READ/ORF_HISTOGRAM
				filename = "GC_HISTOGRAM_" & arguments.libraryId & ".xml";
				if(arguments.type eq 1)
					filename = "READ_HISTOGRAM_" & arguments.libraryId & ".xml";
				else if (arguments.type eq 3)
					filename = "ORF_HISTOGRAM_" & arguments.libraryId & ".xml";
						
				//if file does not exist create a new one		
				if (not fileExists(request.xDocsFilePath&"/"&filename)){				
					//get size or gc --->
					qry = getSequenceSizeOrGC(libraryId=arguments.libraryId,server=arguments.server,type=arguments.type);
				
					//calculate total number of bins
					if (arguments.type neq 0){
						k = 30;
						max = qry["hval"][1];
						min = qry["hval"][qry.recordcount];
						bin = round((max-min)/k);
					} else {
						k = 21;
						bin = 5;
						max = 100;
						min = 0;
					}
	
					//set range of bins, and init temp array
					range_list = min;
					t.arr = ArrayNew(1);
					for(idx=1; idx lt k; idx++){
						range_list = listprepend(range_list,min+(bin*idx));
						t.arr[idx] = 0;
					}
					//above loop is from 1 to k-1 since k elment (min) is already added outside the loop.
					t.arr[k]=0;
					
					//populate frequence count for each bin
					for(i=1; i lte qry.recordcount; i++){
						for (p=1; p lte listLen(range_list); p++){
							if (qry["hval"][i] gte listGetAt(range_list,p)){
									
								//calcuate array index in asc order, currently range_list in desc order.
								arr_idx = abs(p-k)+1;
								t.arr[arr_idx]++;

								//since we found respective range end inner loop
								p = listLen(range_list)+1;
							}
						}
					}
					
					//reverse list in asc order
					rev_list= listSort(range_list,"numeric","asc");
			
					//create key value pair each bin
					for (idx=1; idx lte arrayLen(t.arr); idx++){
						ArrayAppend(root.xmlChildren,XmlElemNew(xroot,"CATEGORY"));
						cat = root.xmlChildren[ArrayLen(root.xmlChildren)];
						cat.XmlAttributes.label = ListGetAt(rev_list,idx).toString();
						cat.XmlAttributes.value = t.arr[idx];
					}
					
					//write to file as well
				
					fileWrite("#request.xDocsFilePath#/#filename#","#xroot#");
				} else {
					xroot = fileRead("#request.xDocsFilePath#/#filename#");
				}
			</cfscript>
			
			<cfcatch type="any">
				<cfset CreateObject("component",  request.cfc & ".Utility").reporterror(method_name="Library", 
																						function_name=getFunctionCalledName(), 
																						args=arguments, 
																						msg=cfcatch.Message, 
																						detail=cfcatch.Detail,
																						tagcontent=cfcatch.tagcontext)>
			</cfcatch>
			
			<cffinally>
				<cfreturn xroot/>
			</cffinally>
		</cftry>
	</cffunction>
	
	<cffunction name="getServerOverview" access="remote" returntype="Array" hint="
				Generate a VIROME level data statistics per environment
					no of read/contig 
					no of ORFs
					megabases of read/contig
					megabases of ORFs
					
				Called directly from Flex by home view
				
				Return: An array of hash per environment.
				">
				
		<cfargument name="userId" type="numeric" required="true" hint="Set to view private libraries for give user"/>
		<cfargument name="libraryIdList" type="string" required="true" hint="Comma separated list of library ID"/>
		<cfargument name="privateOnly" type="boolean" required="true" default="false" hint="Flag to get stats for private libraries only"/>
			
		<cfset local.arr = ArrayNew(1)/>
		
		<cftry>
			<!--- set public/private filename --->
			<cfset filename = "SERVEROVERVIEW_PUBLIC.json"/>
			<cfif arguments.userId gt 0>
				<cfset filename = "SERVEROVERVIEW_PRIVATE_" & arguments.userId & ".json"/>
			</cfif>
			
			<cfif not fileExists(request.xDocsFilePath&"/"&filename)>
				<!--- get environment --->				
				<cfset lib = getLibrary(libraryIdList=arguments.libraryIdList, publish=iif(arguments.privateOnly,"""0""","""-1""") )/>
				<cfset str = ""/>
								
				<cfscript>
					total_no_reads = 0; total_read_mb = 0; total_no_orfs = 0; total_orf_mb = 0; total_no_libs=0;
				</cfscript>
				
				<cflog type="information" text="lib: #lib.RecordCount#" file="virome.library" >
				
				<!--- for each environment get simple library stats --->
				<cfoutput query="lib" group="environment">
					<cfset idList = ""/>
					
					<cfoutput>
						<cfset idList = listAppend(idList, lib.id) />
					</cfoutput>
					<cflog type="information" text="env: #lib.environment#" file="virome.library" >
					
					<cfscript>
						tStruct = StructNew();
						tStruct = serverOverviewHelper(environment=lib.environment,libraryId=idList);
						
						if (tStruct.NO_LIBS){
							total_no_reads += tStruct.NO_READS;
							total_read_mb += tStruct.READ_MB;
							total_no_orfs += tStruct.NO_ORFS;
							total_orf_mb += tStruct.ORF_MB;
							total_no_libs += tStruct.NO_LIBS;
							
							StructInsert(tStruct, "M_READ_SIZE", tStruct.READ_MB/tStruct.NO_READS);
							StructInsert(tStruct, "M_ORF_SIZE", tStruct.ORF_MB/tStruct.NO_ORFS);
							
							StructUpdate(tStruct, "READ_MB", tStruct.READ_MB/1000000);						
							StructUpdate(tStruct, "ORF_MB", (tStruct.ORF_MB*3)/1000000);	
						} else {
							StructInsert(tStruct, "M_READ_SIZE", 0);
							StructInsert(tStruct, "M_ORF_SIZE", 0);
						}
						
						StructInsert(tStruct, "ENVIRONMENT", #lib.environment#);
						ArrayAppend(local.arr,tStruct);
					</cfscript>
					
				</cfoutput>
				
				<cfscript>
					tStruct = StructNew();
					StructInsert(tStruct, "ENVIRONMENT", "Total");
					StructInsert(tStruct, "NO_LIBS", total_no_libs);
					StructInsert(tStruct, "NO_READS", total_no_reads);
					StructInsert(tStruct, "READ_MB", total_read_mb/1000000);
					StructInsert(tStruct, "M_READ_SIZE", total_read_mb/total_no_reads);
					StructInsert(tStruct, "NO_ORFS", total_no_orfs);
					StructInsert(tStruct, "ORF_MB", (total_orf_mb*3)/1000000);
					StructInsert(tStruct, "M_ORF_SIZE", total_orf_mb/total_no_orfs);
					ArrayAppend(local.arr, tStruct);
					
					tStruct = StructNew();					
					StructInsert(tStruct,"ServerOverview",local.arr);
					
					jsonHelper(tStruct,request.xDocsFilePath&"/"&filename);
				</cfscript>
			<cfelse>
				<cfscript>
					data = FileRead(request.xDocsFilePath&"/"&#filename#);
					ov_struct = StructNew();
									
					if(not isNull(data))
						ov_struct = deserializeJSON(data);
					
					local.arr = ov_struct['ServerOverview'];
				</cfscript>
			</cfif>
						
			<cfcatch type="any">
				<cfset CreateObject("component",  request.cfc & ".Utility").reporterror(method_name="Library", 
																						function_name=getFunctionCalledName(), 
																						args=arguments, 
																						msg=cfcatch.Message, 
																						detail=cfcatch.Detail,
																						tagcontent=cfcatch.tagcontext)>
			</cfcatch>
			
			<cffinally>
				<cfreturn local.arr/>
			</cffinally>
		</cftry>
	</cffunction>
	
	<!--- functions for virome submission ---->
		
	<cffunction name="edit_library" access="remote" returntype="Struct" hint="
				Allow ability to edit library metadata such as
					description
					environment
					project
					sequencing method
				
				Used by VIROME library submission applicaiton
				
				Return: A hash of update library info
				">
				
		<cfargument name="obj" type="struct" required="true" hint="A hash library info to modify">
		
		<cftry>
			<cfset struct= StructNew()>
			<cfset struct['MSG'] = "failed"/>
			<cfset struct['ERROR'] = ""/>
			
			<cfset srv = serverName(arguments.obj.environment)/>
			
			<cfquery name="q" datasource="#request.mainDSN#" >
				UPDATE library
				SET	name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.name#">,
					description = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.description#">,
					environment = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.environment#" >,
					project = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.project#">,
					seqMethod = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.seqMethod#">,
					publish = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.obj.publish#" >,
					server = <cfqueryparam cfsqltype="cf_sql_varchar" value="#srv#" >
				WHERE	prefix = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.prefix#">
					and	name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.old_name#">
			</cfquery>
			
			<cfset struct['MSG'] = "Library <b>#arguments.obj.name#</b> modified successfully."/>
			
			<cfcatch type="any">
				<cfset CreateObject("component",  request.cfc & ".Utility").reporterror(method_name="Library", 
																						function_name=getFunctionCalledName(), 
																						args=arguments, 
																						msg=cfcatch.Message, 
																						detail=cfcatch.Detail,
																						tagcontent=cfcatch.tagcontext)>
				<cfset struct['ERROR'] = cfcatch.message/>
			</cfcatch>
			
			<cffinally>
				<cfreturn struct/>		
			</cffinally>
		</cftry>
	</cffunction>
	
	<!--- <cffunction name="add_library" access="remote" returntype="struct" hint="
				Add new library information to be processed
				
				Used by VIROME library submission pipeline
				
				Return: A hash of library info added.
				">
				
		<cfargument name="obj" type="struct" required="true" hint="A hash of library info to add">
		
		<cftry>
			<cfset struct= StructNew()>
			<cfset struct['MSG'] = "failed"/>
			<cfset struct['ERROR'] = ""/>
			
			<cfset prefix = arguments.obj.prefix/>
			<cfif prefix eq "">
				<cfset prefix = getPrefix()/>
			</cfif>
				
			<cfset struct['PREFIX'] = prefix/>
			<cfset srv = serverName(arguments.obj.environment)/>
			<cfset groupId = getGroupId(arguments.obj.user)/>
			
			<!--- check if library name already exists --->
			<cfquery name="x" datasource="#request.mainDSN#" result="rs">
				SELECT	l.`name`
				FROM	library l
				WHERE	l.`name` = '#arguments.obj.name#'
			</cfquery>
			
			<cfif x.RecordCount>
				<cfset struct['ERROR'] = "Library by the name #arguments.obj.name# already exists. Submission terminated."/>
				<cfreturn struct/>
			</cfif>
			
			<cftransaction>
				<cfquery name="a" datasource="#request.mainDSN#">
					INSERT INTO library(name, prefix, description, environment, project, publish, user, seqMethod, progress, groupId, server, deleted, lib_new)
					VALUES	(<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.name#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#prefix#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.description#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.environment#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.project#">,
							<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.obj.publish#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.user#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.sequence_method#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="standby">,
							<cfqueryparam cfsqltype="cf_sql_integer" value="#groupId#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#srv#">,
							<cfqueryparam cfsqltype="cf_sql_tinyint" value="#arguments.obj.deleted#">,
							<cfqueryparam cfsqltype="cf_sql_tinyint" value="#arguments.obj.lib_new#">
							)
				</cfquery>
				
				<cfquery name="g" datasource="#request.mainDSN#">
					SELECT MAX(id) as lastInsert FROM library
				</cfquery>
				
				<cfset libId = g.lastInsert/>
				
				<cfquery name="s" datasource="#request.mainDSN#" >
					INSERT INTO lib_summary(libraryId, lib_name, lib_prefix, lib_shortname, citation, seq_type, 
											amplification, seq_center, lib_type, na_type, project, num_sites, 
											region, geog_place_name, country, lat_deg, lat_hem, lon_deg, lon_hem,
											sample_date, file_type, file_name, assembled, pooled, identifiers,
											ncbi_submission, temp_c, pH, filter_lower_um, filter_upper_um,
											genesis, sphere, ecosystem, extreme, physio_chem_mods, phys_subst, 
											deleted)
					VALUES (<cfqueryparam cfsqltype="cf_sql_integer" value="#libId#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.name#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#prefix#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.name#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.citation#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.sequence_method#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.amplification#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.sequence_center#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.metagenome_type#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.acid_type#">,
							
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.project#">,
							
							<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.obj.sites#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.region#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.place#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.country#">,
							
							<cfqueryparam cfsqltype="cf_sql_float" value="#arguments.obj.lat_degree#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.lat_hem#">,
							<cfqueryparam cfsqltype="cf_sql_float" value="#arguments.obj.long_degree#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.long_hem#">,
							
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.sample_date#">,
							
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.file_type#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.file#">,
							
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.assembled#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.pooling#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.identifier#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.ncbi#">,
							
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.temperature#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.ph#">,
							
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.lb_microbes#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.ub_microbes#">,
							
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.genesis#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.sphere#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.ecosystem#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.extreme#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.physio_chem_mods#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.obj.phys_subst#">,
							
							<cfqueryparam cfsqltype="cf_sql_tinyint" value="#arguments.obj.deleted#">
							)
				</cfquery>
			</cftransaction>
			
			<cfset struct['MSG'] = "Library <b>#arguments.obj.name#</b> added successfully."/>
			
			<cfcatch type="any">
				<cfset CreateObject("component",  request.cfc & ".Utility").reporterror(method_name="Library", 
																						function_name=getFunctionCalledName(), 
																						args=arguments, 
																						msg=cfcatch.Message, 
																						detail=cfcatch.Detail,
																						tagcontent=cfcatch.tagcontext)>
				<cfset struct['ERROR'] = cfcatch.message/>
			</cfcatch>
			
			<cffinally>
				<cfreturn struct/>
			</cffinally>
		</cftry>
	</cffunction> --->
		
	<!--- <cffunction name="delete_library" access="remote" returntype="Struct" hint="
				Logically delete library that hasn't been processed  yet
				
				Used by VIROME library submission pipeline
				
				Return: A hash of library set to logically delete
				">
				
		<cfargument name="obj" type="struct" required="true" hint="A hash of library information">
		
		<cftry>
			<cfset struct= StructNew()>
			<cfset struct['MSG'] = "failed"/>
			<cfset struct['ERROR'] = ""/>
		
			<cftransaction>
				<cfquery name="a" datasource="#request.mainDSN#" >
					DELETE FROM library WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.obj.libraryId#"/>
				</cfquery>
				
				<cfquery name="b" datasource="#request.mainDSN#">
					DELETE FROM lib_summary where libraryId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.obj.libraryId#">
				</cfquery>
			</cftransaction>
			
			<cfset struct['MSG'] = "Library <b>#arguments.obj.name#</b> deleted successfully."/>
			
			<cfcatch type="any">
				<cfset CreateObject("component",  request.cfc & ".Utility").reporterror(method_name="Library", 
																						function_name=getFunctionCalledName(), 
																						args=arguments, 
																						msg=cfcatch.Message, 
																						detail=cfcatch.Detail,
																						tagcontent=cfcatch.tagcontext)>
				<cfset struct['ERROR'] = cfcatch.Message/>
			</cfcatch>
			
			<cffinally>
				<cfif struct["MSG"] neq "failed">
					<!---<cfset CreateObject("component", request.cfc & ".Utility").reportLibrarySubmission(obj, "delete")/>--->
				</cfif>
				<cfreturn struct/>		
			</cffinally>
		</cftry>
	</cffunction> --->
	
	<cffunction name="serverName" access="private" returntype="string" hint="
				Get a server/dataase name based on environment
				A helper function for:
					edit_library()
					add_library()
					
				Return: A string
				">
				
		<cfargument name="environment" type="string" required="true" >
		
		<cfswitch expression="#lcase(arguments.environment)#">
			<cfcase value="extreme"> <cfreturn "thalia"> </cfcase>
			<cfcase value="solid substrate"> <cfreturn "thalia"> </cfcase>
			<cfcase value="organismal substrate"> <cfreturn "calliope"> </cfcase>
			<cfcase value="sediment"> <cfreturn "calliope"> </cfcase>
			<cfcase value="soil"> <cfreturn "polyhymnia"> </cfcase>
			<cfcase value="water"> <cfreturn "terpsichore"> </cfcase>			
			<cfdefaultcase> <cfreturn "calliope"> </cfdefaultcase>
		</cfswitch>
	</cffunction>
	 
	<cffunction name="getGroupId" access="private" returntype="Numeric" hint="
				Get group id user belongs to
				
				A helper function for:
					add_library()
					
				Return: A group number
				">
		<cfargument name="username" type="string" required="true">
		<cfset groupId = -1>
		
		<cftry>
			<cfquery name="q" datasource="#request.mainDSN#">
				SELECT	id
				FROM	groups
				WHERE	name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.username#">
			</cfquery>
			
			<cfloop query="q">
				<cfset groupId = q.id/>	
			</cfloop>
				
			<cfcatch type="any">
				<cfset CreateObject("component",  request.cfc & ".Utility").reporterror(method_name="Library", 
																						function_name=getFunctionCalledName(), 
																						args=arguments, 
																						msg=cfcatch.Message, 
																						detail=cfcatch.Detail,
																						tagcontent=cfcatch.tagcontext)>
				<cfset struct['ERROR'] = cfcatch.Message/>
			</cfcatch>
			
			<cffinally>
				<cfreturn groupId/>
			</cffinally>
		</cftry>
	</cffunction> 
	
	<cffunction name="getPrefix" access="private" returntype="String" hint="
				Assign a unique 3 letter alpha/numeric string for each new library
				
				A helper function for:
					add_library()
					
				Return: A string 
				">
		<cfset prefix = ""/>
		<cfset stop = false/>
		
		<cftry>
			<cfloop condition="stop eq false">
				<cfset prefix = ucase(createPrefix())/>
				
				<cfquery name="q" datasource="#request.mainDSN#">
					SELECT	id
					FROM	library
					WHERE	prefix = '#prefix#'	
				</cfquery>
				
				<cfif (q.recordcount eq 0) and (len(prefix) eq 3)>
					<cfset stop = true/>
				</cfif>
			</cfloop>
			
			<cfcatch type="any">
				<cfset CreateObject("component",  request.cfc & ".Utility").reporterror(method_name="Library", 
																						function_name=getFunctionCalledName(), 
																						args=arguments, 
																						msg=cfcatch.Message, 
																						detail=cfcatch.Detail,
																						tagcontent=cfcatch.tagcontext)>
			</cfcatch>
			
			<cffinally>
				<cfreturn prefix/>
			</cffinally>			
		</cftry>
	</cffunction>
	
	<cffunction name="createPrefix" access="private" returntype="String" hint="
				Generate a 3 letter alpha/numeric string
				
				A helper function for:
					getPrefix()
					
				Return: A string
				">
		<cfset str = ""/>
		<cfloop index="i" from="1" to="3" step="1">
			<cfset a = randrange(48,122)/>
			
			<cfif (#a# gt 57 and #a# lt 65) or (#a# gt 90 and #a# lt 97)>
			<cfelse>
				<cfset str &= #chr(a)#>
			</cfif>
		</cfloop>
		
		<cfreturn str/>
	</cffunction>
	 
</cfcomponent>
