/****** Object:  StoredProcedure [dbo].[AFMS_UPDATE_S4]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AFMS_UPDATE_S4] (
 @Ac_ActivityMajor_CODE       CHAR(4),
 @Ac_ActivityMinor_CODE       CHAR(5),
 @Ac_Reason_CODE              CHAR(2),
 @Ac_ActivityMajorNext_CODE   CHAR(4),
 @Ac_ActivityMinorNext_CODE   CHAR(5),
 @Ac_Notice_ID                CHAR(8),
 @Ac_Recipient_CODE           CHAR(2),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : AFMS_UPDATE_S4
  *     DESCRIPTION       : Update the End Validity date to system date for the given Major and Minor Activity code, code given for the form, reason to update the current Minor Activity when End Validity date is equal to High date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 09-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  UPDATE AFMS_Y1
     SET EndValidity_DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME()
   WHERE ActivityMajor_CODE = @Ac_ActivityMajor_CODE
     AND ActivityMinor_CODE = @Ac_ActivityMinor_CODE
     AND Reason_CODE = @Ac_Reason_CODE
     AND ActivityMajorNext_CODE = @Ac_ActivityMajorNext_CODE
     AND ActivityMinorNext_CODE = @Ac_ActivityMinorNext_CODE
     AND Notice_ID = @Ac_Notice_ID
     AND Recipient_CODE = @Ac_Recipient_CODE
     AND TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     AND EndValidity_DATE = @Ld_High_DATE;

  DECLARE @Ln_RowsAffected_NUMB NUMERIC(10);

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
 END; --End Of AFMS_UPDATE_S4

GO
