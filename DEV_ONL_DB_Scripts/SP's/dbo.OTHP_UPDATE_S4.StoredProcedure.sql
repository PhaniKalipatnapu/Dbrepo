/****** Object:  StoredProcedure [dbo].[OTHP_UPDATE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_UPDATE_S4] (
 @An_OtherParty_IDNO          NUMERIC(9,0),
 @Ac_ReceivePaperForms_INDC   CHAR(1),
 @Ad_Process_DATE             DATE,
 @Ac_WorkerUpdate_ID          CHAR(30),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0)
 )
AS
 /*
   *     PROCEDURE NAME    : OTHP_UPDATE_S4
   *     DESCRIPTION       : Updates process indicator to Y for a given employer.
   *     DEVELOPED BY      : IMP Team
   *     DEVELOPED ON      : 03-AUG-2012
   *     MODIFIED BY       : 
   *     MODIFIED ON       : 
   *     VERSION NO        : 1
   */
 BEGIN
  DECLARE @Ld_Systemdate_DTTM DATETIME2 = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE DATE = '12/31/9999',
          @Lc_ProcessYes_INDC CHAR(1) = 'Y';

  UPDATE OTHP_Y1
         SET EndValidity_DATE = @Ad_Process_DATE
      OUTPUT Deleted.OtherParty_IDNO,
             Deleted.TypeOthp_CODE,
             Deleted.OtherParty_NAME,
             Deleted.Aka_NAME,
             Deleted.Attn_ADDR,
             Deleted.Line1_ADDR,
             Deleted.Line2_ADDR,
             Deleted.City_ADDR,
             Deleted.Zip_ADDR,
             Deleted.State_ADDR,
             Deleted.Fips_CODE,
             Deleted.Country_ADDR,
             Deleted.DescriptionContactOther_TEXT,
             Deleted.Phone_NUMB,
             Deleted.Fax_NUMB,
             Deleted.ReferenceOthp_IDNO,
             Deleted.NewOtherParty_IDNO,
             Deleted.Fein_IDNO,
             Deleted.Contact_EML,
             Deleted.ParentFein_IDNO,
             Deleted.InsuranceProvided_INDC,
             Deleted.Sein_IDNO,
             Deleted.County_IDNO,
             Deleted.DchCarrier_IDNO,
             Deleted.Nsf_INDC,
             Deleted.Verified_INDC,
             Deleted.Note_INDC,
             Deleted.Eiwn_INDC,
             Deleted.Enmsn_INDC,
             Deleted.NmsnGen_INDC,
             Deleted.NmsnInst_INDC,
             Deleted.Tribal_CODE,
             Deleted.Tribal_INDC,
             @Ad_Process_DATE AS BeginValidity_DATE,
             @Ld_High_DATE AS EndValidity_DATE,
             Deleted.WorkerUpdate_ID,
             @Ld_Systemdate_DTTM AS Update_DTTM,
             @An_TransactionEventSeq_NUMB AS TransactionEventSeq_NUMB,
             Deleted.SendShort_INDC,
             Deleted.PpaEiwn_INDC,
             Deleted.DescriptionNotes_TEXT,
             Deleted.Normalization_CODE,
             Deleted.EportalSubscription_INDC,
             Deleted.BarAtty_NUMB,
             @Ac_ReceivePaperForms_INDC AS ReceivePaperForms_INDC
        INTO OTHP_Y1
       WHERE OtherParty_IDNO = @An_OtherParty_IDNO
         AND TransactionEventSeq_NUMB = (SELECT MAX(o.TransactionEventSeq_NUMB)
                                           FROM OTHP_Y1 o
                                          WHERE o.OtherParty_IDNO = @An_OtherParty_IDNO
                                            AND o.EndValidity_DATE = @Ld_High_DATE)
         AND EndValidity_DATE = @Ld_High_DATE;
 END;


GO
