/****** Object:  StoredProcedure [dbo].[DSBL_RETRIEVE_S18]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DSBL_RETRIEVE_S18] (
 @Ac_CheckRecipient_CODE CHAR(1),
 @Ad_Disburse_DATE       DATE,
 @An_DisburseSeq_NUMB    NUMERIC(4, 0),
 @Ac_CheckRecipient_ID   CHAR(10),
 @An_Case_IDNO           NUMERIC(6, 0) OUTPUT,
 @Ac_TypeDisburse_CODE   CHAR(5) OUTPUT
 )
AS
 /*    
  *     PROCEDURE NAME    : DSBL_RETRIEVE_S18    
  *     DESCRIPTION       : Retrieves the Case Id and Disburse Code associated with a recipient. 
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 01-FEB-2011
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
  */
 BEGIN
  SET @An_Case_IDNO = NULL
  SET @Ac_TypeDisburse_CODE = NULL

  DECLARE @Ld_High_DATE DATE = '31-DEC-9999';

  SELECT TOP 1 @An_Case_IDNO = a.Case_IDNO,
               @Ac_TypeDisburse_CODE = a.TypeDisburse_CODE
    FROM dbo.DSBL_Y1 a,
         dbo.DSBH_Y1 b
   WHERE b.CheckRecipient_ID = @Ac_CheckRecipient_ID
     AND b.CheckRecipient_ID = a.CheckRecipient_ID
     AND b.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
     AND b.CheckRecipient_CODE = a.CheckRecipient_CODE
     AND b.EndValidity_DATE = @Ld_High_DATE
     AND b.Disburse_DATE = a.Disburse_DATE
     AND b.DisburseSeq_NUMB = a.DisburseSeq_NUMB
     AND a.Disburse_DATE = @Ad_Disburse_DATE
     AND a.DisburseSeq_NUMB = @An_DisburseSeq_NUMB;
 END


GO
