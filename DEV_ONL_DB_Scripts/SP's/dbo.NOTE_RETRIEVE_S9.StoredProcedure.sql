/****** Object:  StoredProcedure [dbo].[NOTE_RETRIEVE_S9]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NOTE_RETRIEVE_S9] (
 @Ac_Category_CODE     CHAR(2),
 @Ac_Subject_CODE      CHAR(5),
 @Ac_TypeContact_CODE  CHAR(2),
 @Ac_Status_CODE       CHAR(1),
 @Ac_WorkerAssigned_ID CHAR(30),
 @Ac_WorkerCreated_ID  CHAR(30),
 @An_County_IDNO       NUMERIC(3, 0),
 @Ad_From_DATE         DATE,
 @Ad_To_DATE           DATE,
 @Ai_RowFrom_NUMB      INT = 1,
 @Ai_RowTo_NUMB        INT = 10,
 @Ai_Count_QNTY        INT
 )
AS
 /*
  *     PROCEDURE NAME    : NOTE_RETRIEVE_S9
  *     DESCRIPTION       : Retrieve Notes details for a Post Number .
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 23-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE                      DATE = '12/31/9999',
          @Lc_CaseRelationshipNcp_CODE       CHAR(1) = 'A',
          @Lc_CaseRelationshipPutFather_CODE CHAR(1) = 'P',
          @Lc_CaseMemberStatusActive_CODE    CHAR(1) = 'A',
          @Lc_ProcessNtwk_ID                 CHAR(4) = 'NTWK',
          @Lc_SubjectNtcnf_CODE              CHAR(5) = 'NTCNF',
          @Li_Zero_NUMB                      SMALLINT = 0;

  SELECT X.Case_IDNO,
         X.Topic_IDNO,
         X.Office_IDNO,
         X.Category_CODE,
         X.Subject_CODE,
         X.CallBack_INDC,
         X.NotifySender_INDC,
         X.TypeContact_CODE,
         X.SourceContact_CODE,
         X.MethodContact_CODE,
         X.Status_CODE,
         X.WorkerAssigned_ID,
         X.WorkerCreated_ID,
         X.Start_DATE,
         X.Due_DATE,
         X.Action_DATE,
         X.Received_DATE,
         X.WorkerUpdate_ID,
         X.Update_DTTM,
         SUBSTRING(X.Member_NAME,1,LEN(Member_NAME)-1) AS Member_NAME,
         (SELECT COUNT (1)
            FROM RESF_Y1 R
           WHERE R.Process_ID = @Lc_ProcessNtwk_ID
             AND R.Type_CODE = @Lc_ProcessNtwk_ID
             AND R.Reason_CODE = X.Status_CODE) AS WorkList_QNTY,
         X.RowCount_NUMB
    FROM (SELECT C.Start_DATE,
                 C.Category_CODE,
                 C.Subject_CODE,
                 C.WorkerAssigned_ID,
                 C.Office_IDNO,
                 C.Status_CODE,
                 C.Case_IDNO,
                 C.Update_DTTM,
                 C.WorkerCreated_ID,
                 C.CallBack_INDC,
                 C.Due_DATE,
                 C.Action_DATE,
                 C.WorkerUpdate_ID,
                  REPLACE( REPLACE((SELECT RTRIM(LAST_NAME)+CASE WHEN RTRIM (SUFFIX_NAME)<>'' THEN ' '+RTRIM(SUFFIX_NAME) ELSE  '' END+CASE WHEN RTRIM(FIRST_NAME)<>'' THEN ' ,'+RTRIM(FIRST_NAME) ELSE  '' END +CASE WHEN RTRIM (MIDDLE_NAME)<>'' THEN ' '+RTRIM(MIDDLE_NAME)ELSE  ''  END  Member_NAME
                 				FROM CMEM_Y1 CM
                 				     JOIN
                 				     DEMO_Y1 D
                 				    ON ( CM.MemberMci_IDNO=D.MemberMci_IDNO)
							WHERE CM.Case_IDNO=C.Case_IDNO
							  AND CM.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
							  AND CM.CaseMemberStatus_CODE=@Lc_CaseMemberStatusActive_CODE
							  FOR XML AUTO ),'<CM Member_NAME="' ,''),'"/>',':') AS Member_NAME,
                 C.NotifySender_INDC,
                 C.TypeContact_CODE,
                 C.MethodContact_CODE,
                 C.SourceContact_CODE,
                 C.Topic_IDNO,				 
                 C.Received_DATE,
                 C.RowCount_NUMB,
                 C.ORD_ROWNUM
            FROM (SELECT A.Start_DATE,
                         A.Category_CODE,
                         A.Subject_CODE,
                         A.WorkerAssigned_ID,
                         A.Office_IDNO,
                         A.Status_CODE,
                         A.Case_IDNO,
                         A.Update_DTTM,
                         A.CallBack_INDC,
                         A.WorkerCreated_ID,
                         A.Due_DATE,
                         A.Action_DATE,
                         A.WorkerUpdate_ID,
                         A.NotifySender_INDC,
                         A.TypeContact_CODE,
                         A.MethodContact_CODE,
                         A.SourceContact_CODE,
                         COUNT (1) OVER () AS RowCount_NUMB,
                         A.Topic_IDNO,
                         A.Received_DATE,
                         ROW_NUMBER () OVER (ORDER BY A.Update_DTTM DESC) AS ORD_ROWNUM
                 FROM (SELECT N.Start_DATE, 
                              N.Category_CODE,
                              N.Subject_CODE,
                              N.WorkerAssigned_ID,
                              N.Office_IDNO,
                              N.Status_CODE,
                              N.Case_IDNO,
                              N.Update_DTTM,
                              N.CallBack_INDC,
                              N.WorkerCreated_ID,
                              N.Due_DATE,
                              N.Action_DATE,
                              N.WorkerUpdate_ID,
                              N.NotifySender_INDC,
                              N.TypeContact_CODE,
                              N.MethodContact_CODE,
                              N.SourceContact_CODE,
                              N.Topic_IDNO,
                              N.Received_DATE,
                              N.Post_IDNO
                             FROM NOTE_Y1 N
                              WHERE N.EndValidity_DATE = @Ld_High_DATE
                                AND N.Post_IDNO = (SELECT MAX(b.Post_IDNO)
                                                     FROM NOTE_Y1 b
                                                     WHERE  N.Topic_IDNO = b.Topic_IDNO
                                                       AND  N.Case_IDNO = b.Case_IDNO      
                                                       AND b.EndValidity_DATE = @Ld_High_DATE)                   
                                AND N.Office_IDNO=ISNULL(@An_County_IDNO,N.Office_IDNO)
                                AND (N.Subject_CODE <> @Lc_SubjectNtcnf_CODE
                                     AND @Ai_Count_QNTY = @Li_Zero_NUMB
                                      OR @Ai_Count_QNTY > @Li_Zero_NUMB)
                                AND (N.WorkerCreated_ID = ISNULL (@Ac_WorkerCreated_ID, N.WorkerCreated_ID))
                                AND (N.WorkerAssigned_ID = ISNULL (@Ac_WorkerAssigned_ID, N.WorkerAssigned_ID))
                                AND (N.Category_CODE = ISNULL (@Ac_Category_CODE, N.Category_CODE))
                                AND (N.Status_CODE = ISNULL (@Ac_Status_CODE, N.Status_CODE))
                                AND (N.Subject_CODE = ISNULL (@Ac_Subject_CODE, N.Subject_CODE))
                                AND (N.TypeContact_CODE = ISNULL (@Ac_TypeContact_CODE, N.TypeContact_CODE))
                                AND (N.Start_DATE BETWEEN @Ad_From_DATE AND @Ad_To_DATE
                                     AND @Ad_From_DATE IS NOT NULL
                                     AND @Ad_To_DATE IS NOT NULL
                                      OR (@Ad_From_DATE IS NULL
                                          AND @Ad_To_DATE IS NULL)
                                      OR (@Ad_From_DATE IS NOT NULL
                                          AND @Ad_To_DATE IS NULL
                                          AND N.Start_DATE >= @Ad_From_DATE)
                                      OR (@Ad_From_DATE IS NULL
                                          AND @Ad_To_DATE IS NOT NULL
                                          AND N.Start_DATE <= @Ad_To_DATE))) A) C
           WHERE (@Ai_RowFrom_NUMB = @Li_Zero_NUMB
               OR (@Ai_RowFrom_NUMB <> @Li_Zero_NUMB
                   AND C.ORD_ROWNUM >= @Ai_RowFrom_NUMB
                   AND C.ORD_ROWNUM <= @Ai_RowTo_NUMB))) X
      
   ORDER BY ORD_ROWNUM;
 END; -- End of NOTE_RETRIEVE_S9



GO
