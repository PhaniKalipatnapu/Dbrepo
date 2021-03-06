/****** Object:  StoredProcedure [dbo].[DHLD_RETRIEVE_S26]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DHLD_RETRIEVE_S26](
 @An_Case_IDNO             NUMERIC(6, 0),
 @An_DisbursementHold_AMNT NUMERIC(15, 2) OUTPUT
 )
AS
 /*                                                                                   
  *     PROCEDURE NAME    : DHLD_RETRIEVE_S26                                          
  *     DESCRIPTION       : Procedure To Retrieve Transaction_AMNT from DHLD_Y1                                                          
  *     DEVELOPED BY      : IMP TEAM                                              
  *     DEVELOPED ON      : 23/11/2011                                          
  *     MODIFIED BY       :                                                           
  *     MODIFIED ON       :                                                           
  *     VERSION NO        : 1                                                         
 */
 BEGIN
  SET @An_DisbursementHold_AMNT = NULL;

  DECLARE @Li_Zero_NUMB              SMALLINT =  0,
          @Lc_StatusReceiptHeld_CODE CHAR(1)  = 'H',
          @Ld_High_DATE              DATE     = '12/31/9999';

  SELECT @An_DisbursementHold_AMNT = ISNULL(SUM(DH.Transaction_AMNT), @Li_Zero_NUMB)
    FROM DHLD_Y1 DH
   WHERE DH.Case_IDNO		 = @An_Case_IDNO
     AND DH.Status_CODE		 = @Lc_StatusReceiptHeld_CODE
     AND DH.EndValidity_DATE = @Ld_High_DATE;
     
 END; --End Of Procedure DHLD_RETRIEVE_S26 


GO
