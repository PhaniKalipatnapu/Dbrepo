/****** Object:  StoredProcedure [dbo].[RCTH_RETRIEVE_S55]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RCTH_RETRIEVE_S55] (
 @Ad_Batch_DATE               DATE,
 @Ac_SourceBatch_CODE         CHAR(3),
 @An_Batch_NUMB               NUMERIC(4, 0),
 @An_SeqReceipt_NUMB          NUMERIC(6, 0),
 @An_EventGlobalBeginSeq_NUMB NUMERIC(19, 0) OUTPUT,
 @Ac_TypeRemittance_CODE      CHAR(3) OUTPUT,
 @An_Case_IDNO                NUMERIC(6, 0) OUTPUT,
 @An_PayorMCI_IDNO            NUMERIC(10, 0) OUTPUT,
 @An_Fee_AMNT                 NUMERIC(11, 2) OUTPUT,
 @An_Employer_IDNO            NUMERIC(9, 0) OUTPUT,
 @Ac_Fips_CODE                CHAR(7) OUTPUT,
 @Ac_CheckNo_TEXT             CHAR(18) OUTPUT,
 @Ac_TypePosting_CODE         CHAR(1) OUTPUT,
 @Ad_Check_DATE               DATE OUTPUT,
 @Ac_Tanf_CODE                CHAR(1) OUTPUT,
 @Ac_TaxJoint_CODE            CHAR(1) OUTPUT,
 @Ac_TaxJoint_NAME            CHAR(35) OUTPUT,
 @Ad_Refund_DATE              DATE OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : RCTH_RETRIEVE_S55
  *     DESCRIPTION       : Retrieves the Receipt details for the Receipt
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 30-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SELECT @An_EventGlobalBeginSeq_NUMB = NULL,
         @Ac_TypeRemittance_CODE = NULL,
         @An_Case_IDNO = NULL,
         @An_PayorMCI_IDNO = NULL,
         @An_Fee_AMNT = NULL,
         @An_Employer_IDNO = NULL,
         @Ac_Fips_CODE = NULL,
         @Ac_CheckNo_TEXT = NULL,
         @Ac_TypePosting_CODE = NULL,
         @Ad_Check_DATE = NULL,
         @Ac_Tanf_CODE = NULL,
         @Ac_TaxJoint_CODE = NULL,
         @Ac_TaxJoint_NAME = NULL,
         @Ad_Refund_DATE = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999',
          @Li_One_NUMB  SMALLINT = 1;

  SELECT @An_EventGlobalBeginSeq_NUMB = X.EventGlobalBeginSeq_NUMB,
         @Ac_TypeRemittance_CODE = X.TypeRemittance_CODE,
         @An_Case_IDNO = X.Case_IDNO,
         @An_PayorMCI_IDNO = X.PayorMCI_IDNO,
         @An_Fee_AMNT = X.Fee_AMNT,
         @An_Employer_IDNO = X.Employer_IDNO,
         @Ac_Fips_CODE = X.Fips_CODE,
         @Ac_CheckNo_TEXT = X.CheckNo_TEXT,
         @Ac_TypePosting_CODE = X.TypePosting_CODE,
         @Ad_Check_DATE = X.Check_DATE,
         @Ac_Tanf_CODE = X.Tanf_CODE,
         @Ac_TaxJoint_CODE = X.TaxJoint_CODE,
         @Ac_TaxJoint_NAME = X.TaxJoint_NAME,
         @Ad_Refund_DATE = X.Refund_DATE
    FROM (SELECT a.TypeRemittance_CODE,
                 a.TypePosting_CODE,
                 a.Employer_IDNO,
                 a.Fips_CODE,
                 a.Check_DATE,
                 a.CheckNo_TEXT,
                 a.Case_IDNO,
                 a.PayorMCI_IDNO,
                 a.TaxJoint_CODE,
                 a.Tanf_CODE,
                 a.Fee_AMNT,
                 a.TaxJoint_NAME,
                 a.EventGlobalBeginSeq_NUMB,
                 ROW_NUMBER() OVER( PARTITION BY a.Batch_DATE, a.SourceBatch_CODE, a.Batch_NUMB, a.SeqReceipt_NUMB ORDER BY a.EventGlobalBeginSeq_NUMB DESC) AS max_seq,
                 a.Refund_DATE
            FROM RCTH_Y1 a
           WHERE a.Batch_DATE = @Ad_Batch_DATE
             AND a.SourceBatch_CODE = @Ac_SourceBatch_CODE
             AND a.Batch_NUMB = @An_Batch_NUMB
             AND a.SeqReceipt_NUMB = @An_SeqReceipt_NUMB
             AND a.EndValidity_DATE = @Ld_High_DATE) AS X
   WHERE X.max_seq = @Li_One_NUMB;
 END --End of RCTH_RETRIEVE_S55

GO
