/****** Object:  StoredProcedure [dbo].[NRRQ_RETRIEVE_S8]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NRRQ_RETRIEVE_S8] (
 @An_Barcode_NUMB   NUMERIC(12, 0),
 @Ac_Notice_ID      CHAR(8) OUTPUT,
 @An_Case_IDNO      NUMERIC(6, 0) OUTPUT,
 @Ac_Recipient_ID   CHAR(10) OUTPUT,
 @Ad_Run_DATE       DATE OUTPUT,
 @Ac_Recipient_CODE CHAR(2) OUTPUT,
 @As_Xml_TEXT       VARCHAR(MAX) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : NRRQ_RETRIEVE_S8
  *     DESCRIPTION       : Retrieve Notice Reprint Request details for a given Notice.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 03-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @As_Xml_TEXT = NULL,
         @Ad_Run_DATE = NULL,
         @Ac_Recipient_CODE = NULL,
         @An_Case_IDNO = NULL,
         @Ac_Notice_ID = NULL,
         @Ac_Recipient_ID = NULL;

  SELECT TOP 1 @Ac_Notice_ID = N1.Notice_ID,
               @An_Case_IDNO = N1.Case_IDNO,
               @Ac_Recipient_ID = N1.Recipient_ID,
               @Ac_Recipient_CODE = N1.Recipient_CODE,
               @Ad_Run_DATE = N1.Generate_DTTM,
               @As_Xml_TEXT = N2.Xml_TEXT
    FROM NRRQ_Y1 N1
         JOIN AXML_Y1 N2
          ON N1.Barcode_NUMB = N2.Barcode_NUMB
   WHERE N1.Barcode_NUMB = @An_Barcode_NUMB
     AND ISNUMERIC(N1.Notice_ID) = 0
 END; -- END OF NRRQ_RETRIEVE_S8


GO
