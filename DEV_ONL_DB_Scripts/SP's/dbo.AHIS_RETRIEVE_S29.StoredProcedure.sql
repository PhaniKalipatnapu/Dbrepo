/****** Object:  StoredProcedure [dbo].[AHIS_RETRIEVE_S29]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AHIS_RETRIEVE_S29] (
 @Ac_CheckRecipient_CODE CHAR(1),
 @Ad_Disburse_DATE       DATE,
 @An_DisburseSeq_NUMB    NUMERIC(4, 0),
 @Ac_CheckRecipient_ID   CHAR(10)
 )
AS
 /*
  *     PROCEDURE NAME    : AHIS_RETRIEVE_S29
  *     DESCRIPTION       : Retrieves address details for the given recipient.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 14-FEB-2012
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Lc_VerificationBad_Status_CODE CHAR(1) = 'B',
          @Ld_High_DATE                   DATE = '12/31/9999';

  SELECT a.TypeAddress_CODE,
         a.Attn_ADDR,
         a.Line2_ADDR,
         a.Line1_ADDR,
         a.City_ADDR,
         a.State_ADDR,
         a.Zip_ADDR,
         a.Country_ADDR,
         a.SourceLoc_CODE,
         a.SourceReceived_DATE,
         a.Status_CODE,
         a.SourceVerified_CODE,
         a.DescriptionComments_TEXT,
         a.DescriptionServiceDirection_TEXT,
         a.TransactionEventSeq_NUMB,
         a.Normalization_CODE,
         a.Begin_DATE
    FROM AHIS_Y1 a,
         DADR_Y1 d
   WHERE a.MemberMci_IDNO = @Ac_CheckRecipient_ID
     AND d.CheckRecipient_ID = @Ac_CheckRecipient_ID
     AND d.CheckRecipient_CODE = @Ac_CheckRecipient_CODE
     AND d.Disburse_DATE = @Ad_Disburse_DATE
     AND d.DisburseSeq_NUMB = @An_DisburseSeq_NUMB
     AND a.Line2_ADDR = d.Line2_ADDR
     AND a.Line1_ADDR = d.Line1_ADDR
     AND a.City_ADDR = d.City_ADDR
     AND a.State_ADDR = d.State_ADDR
     AND a.Zip_ADDR = d.Zip_ADDR
     AND a.Country_ADDR = d.Country_ADDR
     AND a.End_DATE = @Ld_High_DATE
     AND a.Status_CODE <> @Lc_VerificationBad_Status_CODE;
 END


GO
