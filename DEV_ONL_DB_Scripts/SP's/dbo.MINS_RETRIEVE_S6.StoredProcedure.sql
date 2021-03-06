/****** Object:  StoredProcedure [dbo].[MINS_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MINS_RETRIEVE_S6] (
 @An_ChildMCI_IDNO NUMERIC(10, 0),
 @Ac_Status_CODE   CHAR(2),
 @Ai_RowFrom_NUMB  INT = 1,
 @Ai_RowTo_NUMB    INT = 10
 )
AS
 /*    
  *     PROCEDURE NAME    : MINS_RETRIEVE_S6    
  *     DESCRIPTION       : Retrieve Unique number assigned by the system to the Insurance Co. of the Participant, Group number of the Participant Insurance, Policy Number of the Participant, Relation to the Policy holder, Code of the Verification Status,etc., for the Dependent Member (for whom the insurance is provided) in Dependant Insurance table with Unique number assigned by the system to the participant (This is the DCN of the NCP or the CP by whom the insurance is provided to the dependent) that exists in Member Demographics table, Unique number assigned by the system to the Insurance Co. of the Participant, Group number of the Participant Insurance and Policy Number of the Participant existing in Member Insurance table for Code of the Verification Status with End Validity Date NOT equal to High Date (31-DEC-9999).
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 14-OCT-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
  */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT X.OthpInsurance_IDNO,
         X.InsuranceGroupNo_TEXT,
         X.PolicyInsNo_TEXT,
         X.Begin_DATE,
         X.Status_CODE,
         X.PolicyHolderRelationship_CODE,
         X.PolicyHolder_NAME,
         X.PolicyHolderSsn_NUMB,
         X.BirthPolicyHolder_DATE,
         X.WorkerUpdate_ID,
         X.Last_NAME,
         X.Suffix_NAME,
         X.First_NAME,
         X.Middle_NAME,
         X.MemberSsn_NUMB,
         X.Birth_DATE,
         X.Row_Count AS RowCount_NUMB
    FROM (SELECT MI.OthpInsurance_IDNO,
                 MI.InsuranceGroupNo_TEXT,
                 MI.PolicyInsNo_TEXT,
                 DI.Begin_DATE,
                 MI.PolicyHolderRelationship_CODE,
                 MI.PolicyHolder_NAME,
                 D.Last_NAME,
                 D.Suffix_NAME,
                 D.First_NAME,
                 D.Middle_NAME,
                 MI.PolicyHolderSsn_NUMB,
                 D.MemberSsn_NUMB,
                 MI.BirthPolicyHolder_DATE,
                 D.Birth_DATE,
                 MI.Status_CODE,
                 MI.WorkerUpdate_ID,
                 COUNT(1) OVER() AS Row_Count,
                 ROW_NUMBER() OVER( ORDER BY DI.Begin_DATE DESC ) AS ORD_ROWNUM
            FROM MINS_Y1 MI
                 JOIN DINS_Y1 DI
                  ON MI.MemberMci_IDNO = DI.MemberMci_IDNO
                     AND MI.OthpInsurance_IDNO = DI.OthpInsurance_IDNO
                     AND MI.InsuranceGroupNo_TEXT = DI.InsuranceGroupNo_TEXT
                     AND MI.PolicyInsNo_TEXT = DI.PolicyInsNo_TEXT
                     AND MI.EndValidity_DATE = DI.EndValidity_DATE
                 JOIN DEMO_Y1 D
                  ON MI.MemberMci_IDNO = D.MemberMci_IDNO
           WHERE DI.ChildMCI_IDNO = @An_ChildMCI_IDNO
             AND MI.EndValidity_DATE = @Ld_High_DATE
             AND MI.Status_CODE = ISNULL(@Ac_Status_CODE, MI.Status_CODE))X
   WHERE ORD_ROWNUM BETWEEN @Ai_RowFrom_NUMB AND @Ai_RowTo_NUMB;
 END -- End of MINS_RETRIEVE_S6

GO
