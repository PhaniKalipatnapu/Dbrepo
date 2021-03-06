/****** Object:  StoredProcedure [dbo].[MSSN_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MSSN_UPDATE_S1] (
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_Enumeration_CODE         CHAR(1),
 @Ac_TypePrimary_CODE         CHAR(1),
 @Ac_SourceVerify_CODE        CHAR(3),
 @Ad_Status_DATE              DATE,
 @Ac_SignedOnWorker_ID        CHAR(30)
 )
AS
 /*
  *     PROCEDURE NAME    : MSSN_UPDATE_S1
  *     DESCRIPTION       : Update Member SSN details into Member SSN table with new Sequence Event Transaction.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_EnumerationBad_CODE	CHAR(1) = 'B',
		  @Ld_Systemdatetime_DTTM	DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE				DATE = '12/31/9999',
          @Lc_Space_TEXT			CHAR(1) = ' ',
		  @Ln_RowsAffected_NUMB		NUMERIC(10);
          
  UPDATE MSSN_Y1
		SET Enumeration_CODE = @Lc_EnumerationBad_CODE,
			SourceVerify_CODE = ISNULL(@Ac_SourceVerify_CODE,@Lc_Space_TEXT),
			Status_DATE = @Ld_Systemdatetime_DTTM,
			BeginValidity_DATE = @Ld_Systemdatetime_DTTM,
			WorkerUpdate_ID = @Ac_SignedOnWorker_ID,
			TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB,
			Update_DTTM = @Ld_Systemdatetime_DTTM
	 OUTPUT
			DELETED.MemberMci_IDNO,
			DELETED.MemberSsn_NUMB,
			DELETED.Enumeration_CODE,
			DELETED.TypePrimary_CODE,
			DELETED.SourceVerify_CODE,
			DELETED.Status_DATE,
			DELETED.BeginValidity_DATE,
			@Ld_SystemDatetime_DTTM AS EndValidity_DATE,
			DELETED.WorkerUpdate_ID,
			DELETED.TransactionEventSeq_NUMB,
			DELETED.Update_DTTM
	   INTO MSSN_Y1
	  WHERE MemberMci_IDNO = @An_MemberMci_IDNO
	    AND Enumeration_CODE = @Ac_Enumeration_CODE
		AND TypePrimary_CODE = @Ac_TypePrimary_CODE
	    AND EndValidity_DATE = @Ld_High_DATE;  
  
  	SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;
 SELECT @Ln_RowsAffected_NUMB AS  RowsAffected_NUMB;
 
 END; -- END of  MSSN_UPDATE_S1


GO
