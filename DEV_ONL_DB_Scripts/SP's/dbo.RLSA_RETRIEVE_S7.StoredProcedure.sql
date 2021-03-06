/****** Object:  StoredProcedure [dbo].[RLSA_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RLSA_RETRIEVE_S7](
 @Ac_Role_ID                  CHAR(10),
 @Ac_Screen_ID                CHAR(4),
 @Ac_ScreenFunction_CODE      CHAR(10),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : RLSA_RETRIEVE_S7
  *     DESCRIPTION       : Retrieve the Row Count for a Role Idno, Screen Idno, Screen Function, and Transaction Event.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10/11/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @An_TransactionEventSeq_NUMB = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @An_TransactionEventSeq_NUMB = R.TransactionEventSeq_NUMB
    FROM RLSA_Y1 R
   WHERE R.Role_ID = @Ac_Role_ID
     AND R.Screen_ID = @Ac_Screen_ID
     AND R.ScreenFunction_CODE = @Ac_ScreenFunction_CODE
     AND R.EndValidity_DATE = @Ld_High_DATE;
 END


GO
