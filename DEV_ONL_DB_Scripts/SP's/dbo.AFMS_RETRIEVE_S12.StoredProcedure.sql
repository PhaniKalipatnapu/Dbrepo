/****** Object:  StoredProcedure [dbo].[AFMS_RETRIEVE_S12]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AFMS_RETRIEVE_S12] (
 @Ac_ActivityMajor_CODE       CHAR(4),
 @Ac_ActivityMinor_CODE       CHAR(5),
 @Ac_Reason_CODE              CHAR(2),
 @Ac_ActivityMajorNext_CODE   CHAR(4),
 @Ac_ActivityMinorNext_CODE   CHAR(5),
 @Ac_Notice_ID                CHAR(8),
 @Ac_Recipient_CODE           CHAR(2),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_Exists_INDC              CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : AFMS_RETRIEVE_S12
  *     DESCRIPTION       : Returns 1 if exists for the given Major and Minor Activity code when event lock sequence number is equal to Unique Sequence Number and End Validity date is equal to High date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 08-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
 
  DECLARE 
   @Lc_No_TEXT	CHAR(1)	= 'N',
   @Lc_Yes_TEXT	CHAR(1)	= 'Y',
   @Ld_High_DATE DATE = '12/31/9999';
   
  SET @Ac_Exists_INDC = @Lc_No_TEXT;	

  SELECT @Ac_Exists_INDC = @Lc_Yes_TEXT
    FROM AFMS_Y1 a
   WHERE a.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
     AND a.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
     AND a.Reason_CODE = @Ac_Reason_CODE
     AND a.ActivityMajorNext_CODE = @Ac_ActivityMajorNext_CODE
     AND a.ActivityMinorNext_CODE = @Ac_ActivityMinorNext_CODE
     AND a.Notice_ID = @Ac_Notice_ID
     AND a.Recipient_CODE = @Ac_Recipient_CODE
     AND a.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     AND a.EndValidity_DATE = @Ld_High_DATE;
 END; -- End Of AFMS_RETRIEVE_S12


GO
