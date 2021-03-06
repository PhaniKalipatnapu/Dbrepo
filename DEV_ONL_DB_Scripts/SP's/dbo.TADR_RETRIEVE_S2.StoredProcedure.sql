/****** Object:  StoredProcedure [dbo].[TADR_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[TADR_RETRIEVE_S2] (
   @An_MemberMci_IDNO            NUMERIC (10),
   @Ad_Batch_DATE                DATE,
   @Ac_SourceBatch_CODE          CHAR (3),
   @An_Batch_NUMB                NUMERIC (4),
   @An_SeqReceipt_NUMB           NUMERIC (6),
   @Ac_Attn_ADDR                 CHAR (40) OUTPUT,
   @As_Line1_ADDR                VARCHAR (50) OUTPUT,
   @As_Line2_ADDR                VARCHAR (50) OUTPUT,
   @Ac_City_ADDR                 CHAR (28) OUTPUT,
   @Ac_State_ADDR                CHAR (2) OUTPUT,
   @Ac_Country_ADDR              CHAR (2) OUTPUT,
   @Ac_Zip_ADDR                  CHAR (15) OUTPUT,
   @Ad_Status_DATE               DATE OUTPUT)
AS
   /*
    *     PROCEDURE NAME     : TADR_RETRIEVE_S2
    *     DESCRIPTION       : Retrieve Address Details for a Member Idno, Status Code and Transaction Event Sequence number.
    *     DEVELOPED BY      : IMP Team
    *     DEVELOPED ON      : 10/20/2011
    *     MODIFIED BY       :
    *     MODIFIED ON       :
    *     VERSION NO        : 1
   */
   BEGIN
      -- Initialize variable
      SELECT @Ac_Attn_ADDR = NULL,
             @As_Line1_ADDR = NULL,
             @As_Line2_ADDR = NULL,
             @Ac_City_ADDR = NULL,
             @Ac_State_ADDR = NULL,
             @Ac_Zip_ADDR = NULL,
             @Ac_Country_ADDR = NULL,
             @Ad_Status_DATE = NULL;

      SELECT @Ac_Attn_ADDR = AD.Attn_ADDR,
             @As_Line1_ADDR = AD.Line1_ADDR,
             @As_Line2_ADDR = AD.Line2_ADDR,
             @Ac_City_ADDR = AD.City_ADDR,
             @Ac_State_ADDR = AD.State_ADDR,
             @Ac_Zip_ADDR = AD.Zip_ADDR,
             @Ac_Country_ADDR = AD.Country_ADDR,
             @Ad_Status_DATE = AD.Batch_DATE
        FROM TADR_Y1 AD
       WHERE     AD.MemberMci_IDNO = @An_MemberMci_IDNO
             AND AD.Batch_DATE = @Ad_Batch_DATE
             AND AD.SourceBatch_CODE = @Ac_SourceBatch_CODE
             AND AD.Batch_NUMB = @An_Batch_NUMB
             AND AD.SeqReceipt_NUMB = @An_SeqReceipt_NUMB;
   END

GO
