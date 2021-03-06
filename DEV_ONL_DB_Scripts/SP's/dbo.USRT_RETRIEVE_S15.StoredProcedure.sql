/****** Object:  StoredProcedure [dbo].[USRT_RETRIEVE_S15]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USRT_RETRIEVE_S15] (
 @Ac_Worker_ID      CHAR(30),
 @An_Case_IDNO      NUMERIC(6, 0),
 @An_MemberMci_IDNO NUMERIC(10, 0),
 @Ai_RowFrom_NUMB   INT,
 @Ai_RowTo_NUMB     INT
 )
AS
 /*
  *     PROCEDURE NAME   : USRT_RETRIEVE_S15
  *     DESCRIPTION      : Retrieve User Restriction details for a Familial Member MCI, Case, and Worker.
  *     DEVELOPED BY     : IMP TEAM
  *     DEVELOPED ON     : 27-OCT-2011
  *     MODIFIED BY      : 
  *     MODIFIED ON      : 
  *     VERSION NO       : 1
  */
 BEGIN
  DECLARE @Lc_Yes_TEXT  CHAR(1) = 'Y',
  		  @Li_Zero_NUMB SMALLINT=0,  
          @Ld_High_DATE DATE = '12/31/9999';

 SELECT X.Worker_ID,
		 X.Case_IDNO,
         X.MemberMci_IDNO,
		 X.BeginValidity_DATE,
         X.TransactionEventSeq_NUMB,
         X.Update_DTTM,
		 X.WorkerUpdate_ID,
         X.Reason_CODE,
         X.RowCount_NUMB
    FROM(SELECT A.Worker_ID,
				A.Case_IDNO,
                A.MemberMci_IDNO,
				A.BeginValidity_DATE,
                A.TransactionEventSeq_NUMB,
                A.Update_DTTM,
				A.WorkerUpdate_ID,
                A.Reason_CODE,
                A.RowCount_NUMB,
                A.ORD_ROWNUM
           FROM(SELECT U.Worker_ID,
					   U.Case_IDNO,
                       U.MemberMci_IDNO,
					   U.BeginValidity_DATE,
                       U.TransactionEventSeq_NUMB,
                       U.Update_DTTM,
					   U.WorkerUpdate_ID,
                       U.Reason_CODE,
                       COUNT(1) OVER() AS RowCount_NUMB,
                       ROW_NUMBER() OVER ( ORDER BY U.Update_DTTM DESC  ) AS ORD_ROWNUM
                     FROM USRT_Y1 U
                    WHERE U.MemberMci_IDNO =  ISNULL(@An_MemberMci_IDNO, U.MemberMci_IDNO)
                     AND U.Case_IDNO       =  ISNULL(@An_Case_IDNO,U.Case_IDNO)
                     AND U.Worker_ID        = ISNULL(@Ac_Worker_ID,U.Worker_ID)
                     AND U.Familial_INDC = @Lc_Yes_TEXT
                     AND U.End_DATE = @Ld_High_DATE
                     AND U.EndValidity_DATE = @Ld_High_DATE) AS A
          WHERE A.ORD_ROWNUM <= @Ai_RowTo_NUMB OR @Ai_RowFrom_NUMB = @Li_Zero_NUMB) AS X
   WHERE X.ORD_ROWNUM >= @Ai_RowFrom_NUMB OR @Ai_RowFrom_NUMB = @Li_Zero_NUMB
   ORDER BY ORD_ROWNUM;

 END; --End Of USRT_RETRIEVE_S15


GO
