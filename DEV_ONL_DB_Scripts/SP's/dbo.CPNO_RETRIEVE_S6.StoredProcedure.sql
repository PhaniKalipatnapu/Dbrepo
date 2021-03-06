/****** Object:  StoredProcedure [dbo].[CPNO_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CPNO_RETRIEVE_S6](
 @An_Case_IDNO           NUMERIC(6),
 @Ac_CheckRecipient_ID   CHAR(10),
 @An_EventGlobalSeq_NUMB NUMERIC(19),
 @As_Line1Notice_TEXT    VARCHAR(50) OUTPUT,
 @As_Line2Notice_TEXT    VARCHAR(50) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CPNO_RETRIEVE_S6
  *     DESCRIPTION       : This Procedure populates data for 'CREC Initiated Notice' pop up screen, the
                            CP Recoupment Notice Details popup will be shown to the worker.
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 12/09/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @As_Line1Notice_TEXT = NULL,
         @As_Line2Notice_TEXT = NULL;

  DECLARE 
          @Lc_CheckRecipientCpNcp_CODE CHAR(1) = '1',
          @Lc_Space_TEXT               CHAR(1) = ' ';

  SELECT @As_Line1Notice_TEXT = @Lc_Space_TEXT,
         @As_Line2Notice_TEXT = @Lc_Space_TEXT
    FROM CPNO_Y1 RN
   WHERE RN.Case_IDNO			= @An_Case_IDNO
     AND RN.CheckRecipient_ID	= @Ac_CheckRecipient_ID
     AND RN.EventGlobalSeq_NUMB = @An_EventGlobalSeq_NUMB
     AND RN.CheckRecipient_CODE = @Lc_CheckRecipientCpNcp_CODE;
     
 END; --END OF Procedure CPNO_RETRIEVE_S6


GO
