/****** Object:  StoredProcedure [dbo].[COMP_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[COMP_UPDATE_S1](
 @An_Case_IDNO                   NUMERIC(6),
 @An_OrderSeq_NUMB	      		 NUMERIC(2),
 @Ac_ComplianceStatus_CODE		 CHAR(2),
 @Ac_NewComplianceStatus_CODE	 CHAR(2),
 @Ad_End_DATE					 DATE,
 @An_TransactionEventSeq_NUMB	 NUMERIC(19),
 @Ac_SignedOnWorker_ID			 CHAR(30)
 )
AS

 /*
  *     PROCEDURE NAME    : COMP_UPDATE_S1
  *     DESCRIPTION       : Logically delete all the valid record 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 12/29/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1.0
  */
 
 BEGIN
  DECLARE @Ld_High_DATE    DATE = '12/31/9999',
          @Ld_Current_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  DECLARE @Ld_Current_DATE DATE = @Ld_Current_DTTM;
/*
This SP logically Update all the Active Compliance for the Particular case_ID when the Support Order is End Dated.
So not using the Primarykey in where clause.
*/
  UPDATE COMP_Y1
     SET EndValidity_DATE = @Ld_Current_DATE
  OUTPUT Deleted.Compliance_IDNO,
		 @An_Case_IDNO,
		 @An_OrderSeq_NUMB,
		 Deleted.ComplianceType_CODE,
		 @Ac_NewComplianceStatus_CODE,
		 Deleted.Effective_DATE,
		 @Ad_End_DATE,
		 Deleted.Compliance_AMNT,
		 Deleted.Freq_CODE,
		 Deleted.NoMissPayment_QNTY,
		 Deleted.OrderedParty_CODE,
		 @Ld_Current_DATE,
		 @Ld_High_DATE,
		 @Ac_SignedOnWorker_ID,
		 @Ld_Current_DTTM,
		 @An_TransactionEventSeq_NUMB,
		 Deleted.Entry_DATE
  INTO COMP_Y1
   WHERE Case_IDNO = @An_Case_IDNO
	 AND OrderSeq_NUMB = @An_OrderSeq_NUMB
	 AND ComplianceStatus_CODE = @Ac_ComplianceStatus_CODE
	 AND End_DATE>@Ad_End_DATE
	 AND End_DATE>@Ld_Current_DATE
     AND EndValidity_DATE = @Ld_High_DATE;

  DECLARE @Li_RowsAffected_NUMB INT = @@ROWCOUNT;

  SELECT @Li_RowsAffected_NUMB AS RowsAffected_NUMB;
  
 END;--END of COMP_UPDATE_S1


GO
