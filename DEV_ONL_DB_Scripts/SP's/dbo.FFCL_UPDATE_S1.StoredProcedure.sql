/****** Object:  StoredProcedure [dbo].[FFCL_UPDATE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FFCL_UPDATE_S1] (
 @Ac_Function_CODE            CHAR(3),
 @Ac_Action_CODE              CHAR(1),
 @Ac_Reason_CODE              CHAR(5),
 @Ac_Notice_ID                CHAR(8),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0)
 )
AS
 /*
  *     PROCEDURE NAME    : FFCL_UPDATE_S1
  *     DESCRIPTION       : Logically delete the valid record for the seven CSENET function, Action code & Reason code for the request made and Unique Sequence Number. 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 21-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE         DATE = '12/31/9999',
          @Ld_Current_DATE      DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ln_RowsAffected_NUMB NUMERIC(10);

  UPDATE FFCL_Y1
     SET EndValidity_DATE = @Ld_Current_DATE
   WHERE Function_CODE = @Ac_Function_CODE
     AND Action_CODE = @Ac_Action_CODE
     AND Reason_CODE = @Ac_Reason_CODE
     AND TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     AND EndValidity_DATE = @Ld_High_DATE
     AND Notice_ID = @Ac_Notice_ID;

  SET @Ln_RowsAffected_NUMB = @@ROWCOUNT;

  SELECT @Ln_RowsAffected_NUMB AS RowsAffected_NUMB;
  
   END; --END OF FFCL_UPDATE_S1


GO
