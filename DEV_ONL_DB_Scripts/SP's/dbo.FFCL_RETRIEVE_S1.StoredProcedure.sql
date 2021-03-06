/****** Object:  StoredProcedure [dbo].[FFCL_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FFCL_RETRIEVE_S1] (
 @Ac_Function_CODE CHAR(3),
 @Ac_Action_CODE   CHAR(1),
 @Ac_Reason_CODE   CHAR(5)
 )
AS
 /*
  *     PROCEDURE NAME    : FFCL_RETRIEVE_S1
  *     DESCRIPTION       : Retrieve Name of the Forms and Unique Sequence Number for a seven CSENET function used for communication, Action code & Reason code for the request made and order by name of the form. 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 24-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT a.Notice_ID,
         a.TransactionEventSeq_NUMB
    FROM FFCL_Y1 a
   WHERE a.Function_CODE = @Ac_Function_CODE
     AND a.Action_CODE = @Ac_Action_CODE
     AND a.Reason_CODE = @Ac_Reason_CODE
     AND a.EndValidity_DATE = @Ld_High_DATE
   ORDER BY a.Notice_ID;
   
 END; --END OF FFCL_RETRIEVE_S1


GO
