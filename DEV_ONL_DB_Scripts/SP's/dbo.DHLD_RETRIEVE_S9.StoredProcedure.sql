/****** Object:  StoredProcedure [dbo].[DHLD_RETRIEVE_S9]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DHLD_RETRIEVE_S9] (
 @An_Case_IDNO			NUMERIC(6),
 @Ac_CheckRecipient_ID	CHAR(10),
 @Ac_ReasonStatus_CODE	CHAR(4),
 @Ai_Count_QNTY			INT OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : DHLD_RETRIEVE_S9  
  *     DESCRIPTION       : Retrieves the record count for a case idno, check recipient code, status code for the end validity date which eqauls high date.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 29-SEP-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
  */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_CheckRecipientCpNcp_CODE	CHAR(1)		= '1',
          @Lc_StatusHeld_CODE           CHAR(1)		= 'H',
          @Lc_StatusReady_CODE          CHAR(1)		= 'R',
          @Ld_High_DATE                 DATE		= '12/31/9999';

  SELECT TOP 1 @Ai_Count_QNTY = COUNT (1)
    FROM DHLD_Y1 d
   WHERE d.Case_IDNO = @An_Case_IDNO
	 AND d.CheckRecipient_ID = @Ac_CheckRecipient_ID
     AND d.CheckRecipient_CODE  = @Lc_CheckRecipientCpNcp_CODE
     AND d.EndValidity_DATE = @Ld_High_DATE
     AND (d.Status_CODE = @Lc_StatusReady_CODE
           OR (d.Status_CODE = @Lc_StatusHeld_CODE
               AND d.ReasonStatus_CODE = @Ac_ReasonStatus_CODE));
 END; --End of DHLD_RETRIEVE_S9

GO
