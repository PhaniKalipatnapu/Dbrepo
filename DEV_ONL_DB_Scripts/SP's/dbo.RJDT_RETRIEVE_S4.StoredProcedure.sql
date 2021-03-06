/****** Object:  StoredProcedure [dbo].[RJDT_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RJDT_RETRIEVE_S4](
    @An_MemberMci_IDNO		             NUMERIC(10,0),
    @An_MemberSsn_NUMB		             NUMERIC(9,0),
    @Ac_TypeArrear_CODE		             CHAR(1),                                            
    @Ac_TransactionType_CODE             CHAR(1), 
    @Ad_Rejected_DATE		             DATE,       
    @Ac_Reject1_CODE		             CHAR(2),       
    @An_TransactionEventSeq_NUMB		 NUMERIC(19,0)         
     )                                                                     
AS      
      
/*      
 *     PROCEDURE NAME    : RJDT_RETRIEVE_S4      
 *     DESCRIPTION       : Retrieving the Old Record for the history maintainence       
 *     DEVELOPED BY      : IMP TEAM   
 *     DEVELOPED ON      : 27-NOV-2011     
 *     MODIFIED BY       :       
 *     MODIFIED ON       :       
 *     VERSION NO        : 1      
 */      
 BEGIN      
		 DECLARE @Ld_High_DATE		DATE  =  '12/31/9999',
				 @Ld_Current_DATE	DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(); 
              		
		  SELECT a.County_IDNO ,
				 a.MemberMci_IDNO,
				 a.MemberSsn_NUMB,
				 a.ArrearIdentifier_IDNO,
				 a.Last_NAME, 
				 a.First_NAME ,
				 a.Arrear_AMNT,
				 a.TypeArrear_CODE,
				 a.TransactionType_CODE ,
				 a.ExcludeIrs_INDC,
				 a.ExcludeAdm_INDC,
				 a.ExcludeFin_INDC ,
				 a.ExcludePas_INDC ,
				 a.ExcludeRet_INDC ,
				 a.ExcludeSal_INDC ,
				 a.ExcludeDebt_INDC,
				 a.ExcludeVen_INDC,
				 a.ExcludeIns_INDC ,
				 a.Rejected_DATE ,
				 a.Reject1_CODE,
				 a.Reject2_CODE ,
				 a.Reject3_CODE,
				 a.Reject4_CODE,
				 a.Reject5_CODE,
				 a.Reject6_CODE ,
				 a.TypeReject1_CODE ,
				 a.TypeReject2_CODE,
				 a.TypeReject3_CODE,
				 a.TypeReject4_CODE,
				 a.TypeReject5_CODE,
				 a.TypeReject6_CODE,
				 a.BeginValidity_DATE,
				 @Ld_Current_DATE AS EndValidity_DATE,
				 a.WorkerUpdate_ID,
				 a.Update_DTTM,
				 @An_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB
			FROM RJDT_Y1 a
           WHERE a.MemberMci_IDNO		= @An_MemberMci_IDNO
			 AND a.MemberSsn_NUMB		= @An_MemberSsn_NUMB
			 AND a.TypeArrear_CODE		= @Ac_TypeArrear_CODE
			 AND a.TransactionType_CODE = @Ac_TransactionType_CODE
			 AND a.Rejected_DATE		= @Ad_Rejected_DATE
			 AND a.Reject1_CODE			= @Ac_Reject1_CODE
			 AND a.EndValidity_DATE		= @Ld_High_DATE;
 
END   --END OF RJDT_RETRIEVE_S4.    


GO
