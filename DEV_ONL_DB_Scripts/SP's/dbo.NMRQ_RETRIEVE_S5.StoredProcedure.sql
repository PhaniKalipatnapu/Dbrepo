/****** Object:  StoredProcedure [dbo].[NMRQ_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NMRQ_RETRIEVE_S5] (
 @An_Barcode_NUMB   NUMERIC(12, 0),
 @Ac_Notice_ID      CHAR(8) OUTPUT,
 @An_Case_IDNO      NUMERIC(6, 0) OUTPUT,
 @Ac_Recipient_ID   CHAR(10) OUTPUT,
 @Ac_Recipient_CODE CHAR(2) OUTPUT,
 @As_Xml_TEXT       VARCHAR(MAX) OUTPUT,
 @Ad_Run_DATE       DATE OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : NMRQ_RETRIEVE_S5
  *     DESCRIPTION       : Retrieve Notice Print Request details for a given Notice.
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

  SELECT @Ac_Recipient_ID = N.Recipient_ID,
         @Ac_Recipient_CODE = N.Recipient_CODE,
         @An_Case_IDNO = N.Case_IDNO,
         @As_Xml_TEXT = NX.Xml_TEXT,
         @Ac_Notice_ID = N.Notice_ID,
         @Ad_Run_DATE = N.Request_DTTM
    FROM NMRQ_Y1 N
         JOIN NXML_Y1 NX
          ON N.Barcode_NUMB = NX.Barcode_NUMB
   WHERE N.Barcode_NUMB = @An_Barcode_NUMB
     AND ISNUMERIC(N.Notice_ID) = 0;
 END; -- End Of Procedure NMRQ_RETRIEVE_S5


GO
