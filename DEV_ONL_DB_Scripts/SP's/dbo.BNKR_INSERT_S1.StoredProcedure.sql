/****** Object:  StoredProcedure [dbo].[BNKR_INSERT_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BNKR_INSERT_S1] (
 @An_MemberMci_IDNO           NUMERIC(10, 0),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_TypeBankruptcy_CODE      CHAR(2),
 @Ad_Filed_DATE               DATE,
 @Ad_BeginBankruptcy_DATE     DATE,
 @Ad_EndBankruptcy_DATE       DATE,
 @Ad_Dismissed_DATE           DATE,
 @Ad_ProofFiling_DATE         DATE,
 @Ad_Discharge_DATE           DATE,
 @Ac_Court_NAME               CHAR(30),
 @An_OthpBnkrCourt_IDNO       NUMERIC(9, 0),
 @An_OthpPlanAdmin_IDNO       NUMERIC(9, 0),
 @An_OthpAtty_IDNO            NUMERIC(9, 0),
 @Ac_SignedOnWorker_ID        CHAR(30)
 )
AS
 /*
  *     PROCEDURE NAME    : BNKR_INSERT_S1
  *     DESCRIPTION       : Insert Member Bankruptcy details with new Sequence Event Transaction and Date on which the Bankruptcy Ends into Member Bankruptcy table for Unique Assigned by the System to the Member.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 04-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Ld_Systemdatetime_DTTM DATETIME2=DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
          @Ld_High_DATE           DATE='12/31/9999';

  INSERT BNKR_Y1
         (MemberMci_IDNO,
          TypeBankruptcy_CODE,
          Filed_DATE,
          BeginBankruptcy_DATE,
          EndBankruptcy_DATE,
          Dismissed_DATE,
          ProofFiling_DATE,
          Discharge_DATE,
          Court_NAME,
          OthpBnkrCourt_IDNO,
          OthpPlanAdmin_IDNO,
          OthpAtty_IDNO,
          BeginValidity_DATE,
          EndValidity_DATE,
          Update_DTTM,
          WorkerUpdate_ID,
          TransactionEventSeq_NUMB)
  VALUES ( @An_MemberMci_IDNO,
           @Ac_TypeBankruptcy_CODE,
           @Ad_Filed_DATE,
           @Ad_BeginBankruptcy_DATE,
           @Ad_EndBankruptcy_DATE,
           @Ad_Dismissed_DATE,
           @Ad_ProofFiling_DATE,
           @Ad_Discharge_DATE,
           @Ac_Court_NAME,
           @An_OthpBnkrCourt_IDNO,
           @An_OthpPlanAdmin_IDNO,
           @An_OthpAtty_IDNO,
           @Ld_Systemdatetime_DTTM,
           @Ld_High_DATE,
           @Ld_Systemdatetime_DTTM,
           @Ac_SignedOnWorker_ID,
           @An_TransactionEventSeq_NUMB );
 END; -- END of BNKR_INSERT_S1


GO
