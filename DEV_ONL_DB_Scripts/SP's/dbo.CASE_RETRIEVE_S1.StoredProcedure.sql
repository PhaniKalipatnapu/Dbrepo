/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S1] (
  @An_Office_IDNO  NUMERIC(3),
  @Ai_RowFrom_NUMB INT,
  @Ai_RowTo_NUMB   INT)
AS
  /*   
  *     PROCEDURE NAME    : CASE_RETRIEVE_S1   
  *     DESCRIPTION       : Retrieve Case Idno and Type, Docket Indo and Type, Confidential Indicator, Custodial Parent Name, 
  *                          Non Custodial Parent Name, and Transaction sequence for an Office, Worker Idno, Role Id, and where Case Status is Open.   
  *     DEVELOPED BY      : IMP Team   
  *     DEVELOPED ON      : 02-SEP-2011   
  *     MODIFIED BY       :    
  *     MODIFIED ON       :    
  *     VERSION NO        : 1   
  */
  BEGIN
    DECLARE
      @Lc_OpenCaseStatus_CODE                  CHAR(1) = 'O',
      @Lc_CpCaseRelationship_CODE              CHAR(1) = 'C',
      @Lc_NcpCaseRelationship_CODE             CHAR(1) = 'A',
      @Lc_PutFatherCaseRelationship_CODE       CHAR(1) = 'P',
      @Lc_ActiveStatusCase_CODE                CHAR(1) = 'A',
      @Lc_Yes_TEXT                             CHAR(1) = 'Y',
      @Lc_No_TEXT                              CHAR(1) = 'N',
	  @Lc_Space_TEXT                           CHAR(1) = ' ',
      @Lc_ChildSupportSupervisorRole_ID        CHAR(10) = 'RP004',
      @Ld_High_DATE                            DATE = '12/31/9999',
      @Ld_Systemdate_DATE                      DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

    WITH NewCase_CTE (Case_IDNO, File_ID, TypeCase_CODE, RespondInit_CODE, Worker_ID, TransactionEventSeq_NUMB, RowCount_NUMB
         ,
         Row_NUMB )
         AS (SELECT Y.Case_IDNO,
                    Y.File_ID,
                    Y.TypeCase_CODE,
                    Y.RespondInit_CODE,
                    Y.Worker_ID,
                    Y.TransactionEventSeq_NUMB,
                    Y.RowCount_NUMB,
                    Y.Row_NUMB
               FROM (SELECT X.Case_IDNO,
                            X.File_ID,
                            X.TypeCase_CODE,
                            X.RespondInit_CODE,
                            X.Worker_ID,
                            X.TransactionEventSeq_NUMB,
                            X.RowCount_NUMB,
                            X.Row_NUMB
                       FROM (SELECT a.Case_IDNO,
                                    a.File_ID,
                                    a.TypeCase_CODE,
                                    a.RespondInit_CODE,
                                    a.Worker_ID,
                                    a.TransactionEventSeq_NUMB,
                                    COUNT(1) OVER() AS RowCount_NUMB,
                                    ROW_NUMBER() OVER( ORDER BY a.Case_IDNO) AS Row_NUMB
                               FROM CASE_Y1 a
                              WHERE a.Office_IDNO=@An_Office_IDNO
                                AND a.StatusCase_CODE=@Lc_OpenCaseStatus_CODE
                                AND EXISTS
                                            (SELECT 1
                                               FROM CWRK_Y1 CW
                                              WHERE CW.Case_IDNO=a.Case_IDNO
                                                AND cw.Effective_DATE<=@Ld_Systemdate_DATE
                                                AND cw.Expire_DATE>@Ld_Systemdate_DATE
                                                AND CW.EndValidity_DATE=@Ld_High_DATE
                                              GROUP BY Case_IDNO
                                             HAVING COUNT(1)=1
                                                    AND MAX(CW.ROLE_ID)=@Lc_ChildSupportSupervisorRole_ID)) X
                      WHERE X.Row_NUMB<=@Ai_RowTo_NUMB) Y
              WHERE Y.Row_NUMB>=@Ai_RowFrom_NUMB)
    SELECT CTE.Case_IDNO,
           (SELECT TOP 1 MHX.CaseWelfare_IDNO
              FROM (SELECT MH.CaseWelfare_IDNO,
                           ROW_NUMBER() OVER( ORDER BY MH.Start_DATE DESC) AS ORD_ROWNUM
                      FROM MHIS_Y1 MH
                     WHERE MH.Case_IDNO=CTE.Case_IDNO
                       AND MH.CaseWelfare_IDNO!=0) MHX) AS CaseWelfare_IDNO,
           (SELECT ISNULL(MAX(CASE
                               WHEN UR.HighProfile_INDC=@Lc_Yes_TEXT
                                     OR UR.Familial_INDC=@Lc_Yes_TEXT
                               THEN @Lc_Yes_TEXT
                               ELSE @Lc_No_TEXT
                              END), @Lc_No_TEXT)
              FROM USRT_Y1 UR
             WHERE UR.Case_IDNO=CTE.Case_IDNO
               AND UR.EndValidity_DATE=@Ld_High_DATE
               AND UR.TransactionEventSeq_NUMB=
                   (SELECT TOP 1 MAX(MUR.TransactionEventSeq_NUMB)
                      FROM USRT_Y1 MUR
                     WHERE MUR.EndValidity_DATE=@Ld_High_DATE
                       AND MUR.Case_IDNO=ur.Case_IDNO)) AS CaseRestriction_CODE,
           CTE.File_ID,
           CTE.TypeCase_CODE,
           CTE.RespondInit_CODE,
           CTE.Worker_ID,
           CTE.TransactionEventSeq_NUMB,
           CPD.First_NAME AS CpFirst_NAME,
           CPD.Middle_NAME AS CpMiddle_NAME,
           CPD.Last_NAME AS CPLast_NAME,
           NCD.First_NAME AS NcpFirst_NAME,
           NCD.Middle_NAME AS NcpMiddle_NAME,
           NCD.Last_NAME AS NcpLast_NAME,
           CTE.RowCount_NUMB
      FROM NewCase_CTE CTE
           LEFT OUTER JOIN CMEM_Y1 CPM
             ON CTE.Case_IDNO=CPM.Case_IDNO
           LEFT OUTER JOIN DEMO_Y1 CPD
             ON CPM.MemberMci_IDNO=CPD.MemberMci_IDNO
           LEFT OUTER JOIN CMEM_Y1 NCM
             ON CTE.Case_IDNO=NCM.Case_IDNO
           LEFT OUTER JOIN DEMO_Y1 NCD
             ON NCM.MemberMci_IDNO=NCD.MemberMci_IDNO
     WHERE ISNULL(NCM.CaseRelationship_CODE, @Lc_Space_TEXT) IN (
           @Lc_NcpCaseRelationship_CODE, @Lc_PutFatherCaseRelationship_CODE)
       AND ISNULL(NCM.CaseMemberStatus_CODE, @Lc_Space_TEXT)=@Lc_ActiveStatusCase_CODE
       AND ISNULL(CPM.CaseRelationship_CODE, @Lc_Space_TEXT)=@Lc_CpCaseRelationship_CODE
       AND ISNULL(CPM.CaseMemberStatus_CODE, @Lc_Space_TEXT)=@Lc_ActiveStatusCase_CODE;
  END


GO
