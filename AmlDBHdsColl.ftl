<#import "/templets/commonQuery/CommonQueryTagMacro.ftl" as CommonQueryMacro>
<#assign bean=JspTaglibs["/WEB-INF/struts-bean.tld"] />

<@CommonQueryMacro.page title="大额删除报文补录">
		<@CommonQueryMacro.CommonQuery id="AmlDBHdsColl" init="false" submitMode="all" navigate="false" >
			<table align="left"  width="100%">
				<tr>
					<td colspan="2">
						<@CommonQueryMacro.Interface id="interface" label="请输入查询条件" colNm="8"/>
					</td>
				</tr>

				<tr>
					<td valign="top">
						<@CommonQueryMacro.PagePilot id="pagequery" maxpagelink="10" showArrow="true" />
					</td>
		    	</tr>

		    	<tr>
		    		<td colspan="2">
						<@CommonQueryMacro.DataTable id ="datatable1" paginationbar="btDel,-,btReport,-,btUnReport" fieldStr="select,ticd,recStatus,repStatus,isComp,subSuccess,reportType,brNo,brNoName[260],workDate,ricd,csnm,ctnm[200],citp[250],ctid[200],aoitp[200],ctnt[200],ctvc[220],cctl[300],ctar[250],ccei[200],cbct[200],ocbt[200],cbcn[200],htdt[150],crcd[250],finc[120],rlfc[250],catp[250],ctac[120],oatm[120],tstm[120],tstp[180],crtp[180],crat[120],tcnm[200],tcit[250],tcid[200],tcat[200],tcac[150],lstUpdTlr,lstUpdTm"   width="100%"  readonly="true"/>
		      		</td>
		    	</tr>
			</table>
		</@CommonQueryMacro.CommonQuery>

	<script language="JavaScript">
	var sysTxdate = ${statics["com.huateng.ebank.business.common.GlobalInfo"].getCurrentInstanceWithoutException().getTxdate()?string("yyyyMMdd")};   
	//初始化查询日期
	function initCallGetter_post() {
		AmlDBHdsColl_interface_dataset.setValue("qworkDateStart",sysTxdate);
		AmlDBHdsColl_interface_dataset.setValue("qworkDateEnd",sysTxdate);
	}
	//初始化查询条件交易方式下拉框
	function tstp_DropDown_beforeOpen(dropDown){
    	BiTreeDataDicSelect_DropDownDataset.setParameter("codeType","TSTP");
    	BiTreeDataDicSelect_DropDownDataset.setParameter("headDataTypeNo","9999");
	}
	//初始化查询条件涉外收支交易分类与代码属性下拉框
 	function tsct_DropDown_beforeOpen(dropDown){
        MtsInOutCodeTreeSelect_DropDownDataset.setParameter("headDataTypeNo","02");
        MtsInOutCodeTreeSelect_DropDownDataset.setParameter("codeType","AML");
	 }
	 
	//交易标识号链接
	function datatable1_ticd_onRefresh(cell,value,record) {
		if (record) {//当存在记录时
			var id = record.getValue("id");
			var ticd = record.getValue("ticd");
			cell.innerHTML = "<a style='text-decoration:none' href=\"JavaScript:doDetail('"+id+"')\">" + ticd + "</a>"
		} else {
			cell.innerHTML="&nbsp;";
		}
	}
	//链接查看详细信息
	function doDetail(id){
		showWin("大额交易信息管理明细","/fpages/hf/ftl/AmlDBHdsCollAdd.ftl?id="+id+"&op=detail","window","flushPage()",window);
	}
	
	//修改按钮
	function btMod_onClickCheck(button){
	var record = AmlDBHdsColl_dataset.firstUnit;
		var chk=0;
		var taskIdArr = new Array();
		var recIds = "";
		var delStatus="";
		var id;
		while(record){
			var temp = record.getValue("select");
			if(temp){
			    id = record.getValue("id");
				taskIdArr[chk] = record.getValue("id");
				recStatus=record.getValue("recStatus");
				var v_subSuccess =record.getValue("subSuccess");
				if(recIds == ""){
					recIds += taskIdArr[chk];
				}else{
					recIds += "@" + taskIdArr[chk];
				}
				chk++;
			}
			record=record.nextUnit;
		}
		if(chk==0){
			alert("请选择要修改的记录！");
			return false;
		}else if(chk>1){
			alert("请选择一条记录！");
			return false;
		}else{
		    if(recStatus=='03'){
		       alert("该条信息记录状态是【已上报待校验】，不能修改！请先撤销上报！");
		       return false;
		    }
		    if(v_subSuccess=="1"){
			    alert("所选信息是【已上报并接收成功回执】的交易，不能补录！");
				return false;
		   }
		showWin("大额交易信息管理修改","/fpages/hf/ftl/AmlDBHdsCollAdd.ftl?id=" + id + "&op=mod","window","flushPage()",window);
		}
	}
	
	//上报
   function btReport_onClickCheck(button){
		var record = AmlDBHdsColl_dataset.firstUnit;
		var chk=0;
		var recIds = "";
		while(record){
			var temp = record.getValue("select");
			if(temp){
			    ticd = record.getValue("ticd");
	            var v_recStatus = record.getValue("recStatus");
				recIds+=ticd
		        recIds+="|";
				chk++;
				 if(v_recStatus!="02"){
				    alert("只能上报【已补录待上报】数据！");
					return false;
				 }
			}
			record=record.nextUnit;
		}
		if(chk==0){
			alert("请选择要上报的记录！");
			return false;
		}else{
			updateReport(recIds,0);	
		}
   }
   
   //撤销上报
   function btUnReport_onClickCheck(button){
		var record = AmlDBHdsColl_dataset.firstUnit;
		var chk=0;
		var recIds = "";
		while(record){
			var temp = record.getValue("select");
			if(temp){
			    ticd = record.getValue("ticd");
	            var v_recStatus = record.getValue("recStatus");
				recIds+=ticd
		        recIds+="|";
				chk++;
				if(v_recStatus!="05"){
				    alert("只能撤销上报【已上报】数据！");
					return false;
				}
			}
			record=record.nextUnit;
		}
		if(chk==0){
			alert("请选择要上报的记录！");
			return false;
		}else{
			updateReport(recIds,1);	
		}
   }

   function updateReport(ids,flag){
		AMLVaildService.updateBHCReport(ids,flag,function(mgs){
			alert(mgs);
			AmlDBHdsColl_dataset.flushData(AmlDBHdsColl_dataset.pageIndex);
		});
	}	
	function btDel_onClickCheck(button){
			showWin("大额交易删除","/fpages/hf/ftl/AmlDBHdsCollAdd.ftl?op=new","window","flushPage()",window);	
		}
	</script>
</@CommonQueryMacro.page>