/****** Object:  StoredProcedure [dbo].[FEDH_DELETE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FEDH_DELETE_S1](
	 @An_MemberSsn_NUMB			NUMERIC(9,0),
	 @Ac_TypeArrear_CODE		CHAR(1),
     @Ac_TypeTransaction_CODE	CHAR(1)
     )
AS    
    
/*    
 *     PROCEDURE NAME    : FEDH_DELETE_S1    
 *     DESCRIPTION       : DELETE THE RECORD FOR THE CORRESPONDING SSN
 *     DEVELOPED BY      : IMP Team 
 *     DEVELOPED ON      : 27-NOV-2011    
 *     MODIFIED BY       :     
 *     MODIFIED ON       :     
 *     VERSION NO        : 1    
 */    
BEGIN    
		DECLARE @Ld_Current_DTTM	DATETIME2(7) = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
		 DELETE FEDH_Y1  
		  
		 OUTPUT	Deleted.MemberMci_IDNO,
				Deleted.MemberSsn_NUMB, 
				Deleted.TypeArrear_CODE,
				Deleted.TypeTransaction_CODE, 
				Deleted.Last_NAME, 
				Deleted.First_NAME,
				Deleted.Middle_NAME, 
				Deleted.Line1_ADDR, 
				Deleted.Line2_ADDR,
				Deleted.City_ADDR, 
				Deleted.State_ADDR, 
				Deleted.Zip_ADDR,
				Deleted.ArrearIdentifier_IDNO, 
				Deleted.Arrear_AMNT,
				Deleted.SubmitLast_DATE, 
				Deleted.ExcludePas_CODE,
				Deleted.ExcludeFin_CODE, 
				Deleted.ExcludeIrs_CODE,
				Deleted.ExcludeAdm_CODE, 
				Deleted.ExcludeRet_CODE,
				Deleted.ExcludeSal_CODE, 
				Deleted.ExcludeDebt_CODE,
				Deleted.ExcludeVen_CODE, 
				Deleted.ExcludeIns_CODE,
				Deleted.RejectInd_INDC, 
				Deleted.CountyFips_CODE,
				Deleted.BeginValidity_DATE, 
				@Ld_Current_DTTM AS EndValidity_DATE,
				Deleted.WorkerUpdate_ID, 
				Deleted.Update_DTTM,
				Deleted.TransactionEventSeq_NUMB, 
				Deleted.ReqPreOffset_CODE,
				Deleted.TaxYear_NUMB
		   INTO HFEDH_Y1	
		  WHERE MemberSsn_NUMB		= @An_MemberSsn_NUMB 
			AND TypeArrear_CODE		= @Ac_TypeArrear_CODE 
			AND TypeTransaction_CODE = @Ac_TypeTransaction_CODE;    
          
		DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);    
      		SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;                          
		 SELECT @Ln_RowsAffected_NUMB;    
		 
END;   --End of FEDH_DELETE_S1.    


GO
