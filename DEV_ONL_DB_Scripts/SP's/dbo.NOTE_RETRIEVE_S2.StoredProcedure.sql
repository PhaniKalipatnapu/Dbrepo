/****** Object:  StoredProcedure [dbo].[NOTE_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NOTE_RETRIEVE_S2] (
 @An_Case_IDNO         NUMERIC(6, 0),
 @An_Topic_IDNO        NUMERIC(10, 0),
 @An_Office_IDNO       NUMERIC(3, 0),
 @Ac_Category_CODE     CHAR(2),
 @Ac_Subject_CODE      CHAR(5),
 @Ac_Status_CODE       CHAR(1),
 @Ac_WorkerAssigned_ID CHAR(30),
 @Ad_From_DATE         DATE,
 @Ad_To_DATE           DATE,
 @Ai_RowFrom_NUMB      INT = 1,
 @Ai_RowTo_NUMB        INT = 10,
 @Ai_Count_QNTY        INT
 )
AS
 /*
  *     PROCEDURE NAME    : NOTE_RETRIEVE_S2
  *     DESCRIPTION       : Retrieve Notes details for a given  Case Topic  and Post number.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 24-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE        DATE = '12/31/9999',
          @Lc_ProcessNtwk_ID   CHAR(4) = 'NTWK',
          @Lc_ProcessConf_ID   CHAR(4) = 'CONF',
          @Li_Zero_NUMB        SMALLINT = 0,
          @Li_Minusthree_NUMB  SMALLINT =-3,        
          @Ld_Current_DATE     DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SELECT Y.Case_IDNO,
         Y.Topic_IDNO,
         Y.TransactionEventSeq_NUMB,
         Y.Office_IDNO,
         Y.Category_CODE,
         Y.Subject_CODE,
         Y.CallBack_INDC,
         Y.NotifySender_INDC,
         Y.TypeContact_CODE,
         Y.SourceContact_CODE,
         Y.MethodContact_CODE,
         Y.Status_CODE,
         Y.WorkerAssigned_ID,
         Y.RoleAssigned_ID,
         Y.WorkerCreated_ID,
         Y.Start_DATE,
         Y.Due_DATE,
         Y.Action_DATE,
         Y.DescriptionNote_TEXT,
         Y.WorkerUpdate_ID,
         Y.Received_DATE,
         Y.TotalReplies_QNTY,
         (SELECT COUNT(1)
            FROM RESF_Y1 R
           WHERE R.Process_ID = @Lc_ProcessNtwk_ID
             AND R.Type_CODE = @Lc_ProcessNtwk_ID
             AND R.Reason_CODE = Y.Status_CODE)AS WorkList_QNTY,
         Y.RowCount_NUMB
    FROM (SELECT X.Case_IDNO,
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
                 X.RoleAssigned_ID,
                 X.WorkerCreated_ID,
                 X.Start_DATE,
                 X.Due_DATE,
                 X.Action_DATE,
                 X.DescriptionNote_TEXT,
                 X.WorkerUpdate_ID,
                 X.TransactionEventSeq_NUMB,
                 X.Received_DATE,
                 X.TotalReplies_QNTY,
                 X.RowCount_NUMB,
                 X.ORD_ROWNUM
            FROM (SELECT N.Case_IDNO,
                         N.Topic_IDNO,
                         N.Office_IDNO,
                         N.Category_CODE,
                         N.Subject_CODE,
                         N.CallBack_INDC,
                         N.NotifySender_INDC,
                         N.TypeContact_CODE,
                         N.SourceContact_CODE,
                         N.MethodContact_CODE,
                         N.Status_CODE,
                         N.WorkerAssigned_ID,
                         N.RoleAssigned_ID,
                         N.WorkerCreated_ID,
                         N.Start_DATE,
                         N.Due_DATE,
                         N.Action_DATE,
                         SUBSTRING (N.DescriptionNote_TEXT, 0, 100) AS DescriptionNote_TEXT,
                         N.WorkerUpdate_ID,
                         N.TransactionEventSeq_NUMB,
                         N.Received_DATE,
                         N.TotalReplies_QNTY,
                         COUNT (1) OVER() AS RowCount_NUMB,
                         ROW_NUMBER() OVER( ORDER BY N.Update_DTTM DESC) AS ORD_ROWNUM
                    FROM NOTE_Y1 N
                   WHERE N.Post_IDNO = (SELECT MAX (b.Post_IDNO)
                                          FROM NOTE_Y1 b
                                         WHERE N.Topic_IDNO = b.Topic_IDNO
                                           AND N.Case_IDNO = b.Case_IDNO
                                           AND b.EndValidity_DATE = @Ld_High_DATE)
                     AND N.EndValidity_DATE = @Ld_High_DATE
                     AND N.MajorIntSeq_NUMB != @Li_Zero_NUMB
                     AND (@Ai_Count_QNTY = @Li_Zero_NUMB
                          AND N.Subject_CODE NOT IN (SELECT C.Reason_CODE
                                                       FROM RESF_Y1 C
                                                      WHERE C.Process_ID = @Lc_ProcessConf_ID)
                           OR @Ai_Count_QNTY <> @Li_Zero_NUMB)
                     AND N.Topic_IDNO=ISNULL(@An_Topic_IDNO,N.Topic_IDNO)
                     AND N.Category_CODE = ISNULL (@Ac_Category_CODE, N.Category_CODE)
                     AND N.WorkerAssigned_ID = ISNULL (@Ac_WorkerAssigned_ID, N.WorkerAssigned_ID)
                     AND N.Office_IDNO = ISNULL(@An_Office_IDNO,N.Office_IDNO)
                     AND N.Case_IDNO = ISNULL(@An_Case_IDNO,N.Case_IDNO)
                     AND N.Status_CODE = ISNULL (@Ac_Status_CODE, N.Status_CODE)
                     AND N.Subject_CODE = ISNULL (@Ac_Subject_CODE, N.Subject_CODE)
                     AND N.Start_DATE BETWEEN ISNULL(@Ad_From_DATE, DATEADD(m, @Li_Minusthree_NUMB, @Ld_Current_DATE)) AND ISNULL(@Ad_To_DATE,@Ld_Current_DATE))AS X
           WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB) AS Y
   WHERE Y.ORD_ROWNUM >= @Ai_RowFrom_NUMB
   ORDER BY Y.ORD_ROWNUM;
 END -- End of NOTE_RETRIEVE_S2


GO
