/****** Object:  StoredProcedure [dbo].[NMRQ_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NMRQ_RETRIEVE_S1] (
 @Ac_Notice_ID    CHAR(8),
 @An_Case_IDNO    NUMERIC(6, 0),
 @Ac_Recipient_ID CHAR(10),
 @Ac_File_ID      CHAR(10),
 @Ad_From_DATE    DATE,
 @Ad_To_DATE      DATE,
 @Ai_RowFrom_NUMB INT =1,
 @Ai_RowTo_NUMB   INT =10
 )
AS
 /*
  *     PROCEDURE NAME    : NMRQ_RETRIEVE_S1
  *     DESCRIPTION       : Retrieve Notice print Request details for a Case. 
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 26-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE          DATE ='12/31/9999',
          @Lc_StatusNoticeG_CODE CHAR='G',
          @Lc_StatusNoticeF_CODE CHAR='F',
          @Li_One_NUMB           SMALLINT=1;

  SELECT H.Notice_ID,
         H.Case_IDNO,
         H.Recipient_ID,
         H.Barcode_NUMB,
         H.TransactionEventSeq_NUMB,
         (SELECT N2.DescriptionNotice_TEXT
            FROM NREF_Y1 N2
           WHERE N2.Notice_ID = H.Notice_ID
             AND N2.EndValidity_DATE = @Ld_High_DATE) DescriptionNotice_TEXT,
         H.Recipient_CODE,
         H.File_ID,
         H.Request_DTTM,
         H.WorkerRequest_ID,
         H.StatusNotice_CODE,
         H.TypeService_CODE,
         H.Recipient_NAME,
         H.RowCount_NUMB
    FROM (SELECT X.Request_DTTM,
                 X.Notice_ID,
                 X.Case_IDNO,
                 X.Recipient_CODE,
                 X.File_ID,
                 X.WorkerRequest_ID,
                 X.StatusNotice_CODE,
                 X.Barcode_NUMB,
                 X.TransactionEventSeq_NUMB,
                 X.Recipient_ID,
                 X.ORD_ROWNUM,
                 X.TypeService_CODE,
                 X.Recipient_NAME,
                 X.RowCount_NUMB
            FROM (SELECT N1.Request_DTTM,
                         N1.Notice_ID,
                         N1.Case_IDNO,
                         N1.Recipient_CODE,
                         C1.File_ID,
                         N1.WorkerRequest_ID,
                         N1.StatusNotice_CODE,
                         N1.Barcode_NUMB,
                         N1.TransactionEventSeq_NUMB,
                         N1.Recipient_ID,
                         N1.TypeService_CODE,
                         N1.Recipient_NAME,
                         COUNT(1) OVER() AS RowCount_NUMB,
                         ROW_NUMBER() OVER ( ORDER BY N1.Request_DTTM DESC ) ORD_ROWNUM
                    FROM NMRQ_Y1 N1
                         JOIN CASE_Y1 C1
                          ON N1.Case_IDNO = C1.Case_IDNO
                   WHERE N1.StatusNotice_CODE IN (@Lc_StatusNoticeG_CODE, @Lc_StatusNoticeF_CODE)
                     AND N1.Request_DTTM BETWEEN @Ad_From_DATE AND DATEADD(D, @Li_One_NUMB, @Ad_To_DATE)
                     AND N1.Case_IDNO = ISNULL(@An_Case_IDNO,N1.Case_IDNO)                         
                     AND C1.File_ID = ISNULL (@Ac_File_ID, C1.File_ID)
                     AND N1.Notice_ID = ISNULL (@Ac_Notice_ID, N1.Notice_ID)
                     AND N1.Recipient_ID = ISNULL(@Ac_Recipient_ID, Recipient_ID)
					 AND ISNUMERIC(N1.Notice_ID) = 0) X
           WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB) H
   WHERE H.ORD_ROWNUM >= @Ai_RowFrom_NUMB;
 END; -- End Of Procedure NMRQ_RETRIEVE_S1


GO
