/****** Object:  StoredProcedure [dbo].[BNKR_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BNKR_RETRIEVE_S1] (
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0) OUTPUT,
 @Ac_TypeBankruptcy_CODE      CHAR(2) OUTPUT,
 @Ad_Filed_DATE               DATE OUTPUT,
 @Ad_BeginBankruptcy_DATE     DATE OUTPUT,
 @Ad_EndBankruptcy_DATE       DATE OUTPUT,
 @Ad_Dismissed_DATE           DATE OUTPUT,
 @Ad_ProofFiling_DATE         DATE OUTPUT,
 @Ad_Discharge_DATE           DATE OUTPUT,
 @Ac_Court_NAME               CHAR(30) OUTPUT,
 @An_OthpBnkrCourt_IDNO       NUMERIC(9, 0) OUTPUT,
 @An_OthpPlanAdmin_IDNO       NUMERIC(9, 0) OUTPUT,
 @An_OthpAtty_IDNO            NUMERIC(9, 0) OUTPUT,
 @Ad_Update_DTTM              DATETIME2 OUTPUT,
 @Ac_WorkerUpdate_ID          CHAR(30) OUTPUT,
 @Ac_History_INDC             CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : BNKR_RETRIEVE_S1
  *     DESCRIPTION       : Retrieve Member Bankruptcy details from Member Bankruptcy table for Unique Number Assigned by the System to the Member.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SELECT @Ac_History_INDC = NULL,
         @Ad_BeginBankruptcy_DATE = NULL,
         @Ad_Discharge_DATE = NULL,
         @Ad_Dismissed_DATE = NULL,
         @Ad_EndBankruptcy_DATE = NULL,
         @Ad_Filed_DATE = NULL,
         @Ad_ProofFiling_DATE = NULL,
         @Ad_Update_DTTM = NULL,
         @An_TransactionEventSeq_NUMB = NULL,
         @An_OthpAtty_IDNO = NULL,
         @An_OthpBnkrCourt_IDNO = NULL,
         @Ac_TypeBankruptcy_CODE = NULL,
         @Ac_WorkerUpdate_ID = NULL,
         @Ac_Court_NAME = NULL,
         @An_OthpPlanAdmin_IDNO = NULL;

  DECLARE @Lc_Yes_INDC  CHAR(1) = 'Y',
          @Lc_No_INDC   CHAR(1) = 'N',
          @Ld_High_DATE DATE = '12/31/9999';

  SELECT TOP 1 @Ac_TypeBankruptcy_CODE = B.TypeBankruptcy_CODE,
               @Ad_Filed_DATE = B.Filed_DATE,
               @Ad_BeginBankruptcy_DATE = B.BeginBankruptcy_DATE,
               @Ad_EndBankruptcy_DATE = B.EndBankruptcy_DATE,
               @Ad_Dismissed_DATE = B.Dismissed_DATE,
               @Ad_ProofFiling_DATE = B.ProofFiling_DATE,
               @Ad_Discharge_DATE = B.Discharge_DATE,
               @Ac_Court_NAME = B.Court_NAME,
               @An_OthpPlanAdmin_IDNO = B.OthpPlanAdmin_IDNO,
               @An_OthpAtty_IDNO = B.OthpAtty_IDNO,
               @An_OthpBnkrCourt_IDNO = B.OthpBnkrCourt_IDNO,
               @An_TransactionEventSeq_NUMB = B.TransactionEventSeq_NUMB,
               @Ac_WorkerUpdate_ID = B.WorkerUpdate_ID,
               @Ad_Update_DTTM = B.Update_DTTM,
               @Ac_History_INDC = ISNULL ((SELECT TOP 1 @Lc_Yes_INDC
                                             FROM BNKR_Y1 h
                                            WHERE h.MemberMci_IDNO = @An_MemberMci_IDNO
                                              AND h.EndValidity_DATE != @Ld_High_DATE), @Lc_No_INDC)
    FROM BNKR_Y1 B
   WHERE B.MemberMci_IDNO = @An_MemberMci_IDNO
     AND B.EndValidity_DATE = @Ld_High_DATE;
 END; -- END of BNKR_RETRIEVE_S1


GO
