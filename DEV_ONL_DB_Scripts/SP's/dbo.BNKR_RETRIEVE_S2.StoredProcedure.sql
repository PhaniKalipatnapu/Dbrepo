/****** Object:  StoredProcedure [dbo].[BNKR_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BNKR_RETRIEVE_S2] (
 @An_MemberMci_IDNO       NUMERIC(10, 0),
 @An_Record_NUMB          NUMERIC(22, 0),
 @Ac_TypeBankruptcy_CODE  CHAR(2) OUTPUT,
 @Ad_Filed_DATE           DATE OUTPUT,
 @Ad_BeginBankruptcy_DATE DATE OUTPUT,
 @Ad_EndBankruptcy_DATE   DATE OUTPUT,
 @Ad_Dismissed_DATE       DATE OUTPUT,
 @Ad_ProofFiling_DATE     DATE OUTPUT,
 @Ad_Discharge_DATE       DATE OUTPUT,
 @Ac_Court_NAME           CHAR(30) OUTPUT,
 @An_OthpBnkrCourt_IDNO   NUMERIC(9, 0) OUTPUT,
 @An_OthpPlanAdmin_IDNO   NUMERIC(9, 0) OUTPUT,
 @An_OthpAtty_IDNO        NUMERIC(9, 0) OUTPUT,
 @Ad_Update_DTTM          DATETIME2 OUTPUT,
 @Ac_WorkerUpdate_ID      CHAR(30) OUTPUT,
 @An_RowCount_NUMB        NUMERIC(6, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : BNKR_RETRIEVE_S2
  *     DESCRIPTION       : Retrieve Member Bankruptcy History details from Member Bankruptcy table for Unique Number Assigned by the System to the Member.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SELECT @Ad_BeginBankruptcy_DATE = NULL,
         @Ad_Discharge_DATE = NULL,
         @Ad_Dismissed_DATE = NULL,
         @Ad_EndBankruptcy_DATE = NULL,
         @Ad_Filed_DATE = NULL,
         @Ad_ProofFiling_DATE = NULL,
         @Ad_Update_DTTM = NULL,
         @An_RowCount_NUMB = NULL,
         @An_OthpAtty_IDNO = NULL,
         @An_OthpBnkrCourt_IDNO = NULL,
         @Ac_TypeBankruptcy_CODE = NULL,
         @Ac_WorkerUpdate_ID = NULL,
         @Ac_Court_NAME = NULL,
         @An_OthpPlanAdmin_IDNO = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ac_TypeBankruptcy_CODE = X.TypeBankruptcy_CODE,
         @Ad_Filed_DATE = X.Filed_DATE,
         @Ad_BeginBankruptcy_DATE = X.BeginBankruptcy_DATE,
         @Ad_EndBankruptcy_DATE = X.EndBankruptcy_DATE,
         @Ad_Dismissed_DATE = X.Dismissed_DATE,
         @Ad_ProofFiling_DATE = X.ProofFiling_DATE,
         @Ad_Discharge_DATE = X.Discharge_DATE,
         @Ac_Court_NAME = X.Court_NAME,
         @An_OthpPlanAdmin_IDNO = X.OthpPlanAdmin_IDNO,
         @An_OthpAtty_IDNO = X.OthpAtty_IDNO,
         @An_OthpBnkrCourt_IDNO = X.OthpBnkrCourt_IDNO,
         @Ac_WorkerUpdate_ID = X.WorkerUpdate_ID,
         @Ad_Update_DTTM = X.Update_DTTM,
         @An_RowCount_NUMB = X.RowCount_NUMB
    FROM (SELECT B.TypeBankruptcy_CODE,
                 B.Court_NAME,
                 B.Filed_DATE,
                 B.ProofFiling_DATE,
                 B.BeginBankruptcy_DATE,
                 B.EndBankruptcy_DATE,
                 B.Dismissed_DATE,
                 B.Discharge_DATE,
                 B.OthpPlanAdmin_IDNO,
                 B.OthpAtty_IDNO,
                 B.OthpBnkrCourt_IDNO,
                 B.WorkerUpdate_ID,
                 B.Update_DTTM,
                 COUNT(1) OVER() AS RowCount_NUMB,
                 ROW_NUMBER() OVER ( ORDER BY B.TransactionEventSeq_NUMB DESC ) AS Rownum_NUMB
            FROM BNKR_Y1 B
           WHERE B.MemberMci_IDNO = @An_MemberMci_IDNO
             AND B.EndValidity_DATE != @Ld_High_DATE) AS X
   WHERE X.Rownum_NUMB = @An_Record_NUMB;
 END; -- END of BNKR_RETRIEVE_S2


GO
