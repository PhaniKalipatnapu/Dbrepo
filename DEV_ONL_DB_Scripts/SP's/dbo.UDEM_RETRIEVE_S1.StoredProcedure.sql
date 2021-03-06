/****** Object:  StoredProcedure [dbo].[UDEM_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[UDEM_RETRIEVE_S1](
	@An_MemberMci_IDNO				NUMERIC(10,0),
	@Ac_TypeUpdate_CODE				CHAR(2),
	@Ac_Source_CODE					CHAR(3),
	@Ad_ReceivedFrom_DATE			DATE,
	@Ad_ReceivedTo_DATE				DATE,
	@Ac_Status_CODE					CHAR(1),
	@Ac_WorkerDelegate_ID			CHAR(30),
	@Ai_RowFrom_NUMB				INT = 1,
	@Ai_RowTo_NUMB					INT = 10
	)
AS

/*
 *     PROCEDURE NAME    : UDEM_RETRIEVE_S1
 *     DESCRIPTION       : Retrieves the Member details that is to be reviewed.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 10-AUG-2011
 *     MODIFIED BY       :
 *     MODIFIED ON       :
 *     VERSION NO        : 1
*/

BEGIN

		DECLARE @Ld_Low_DATE				DATE	= '01/01/0001',
				@Ld_High_DATE				DATE	= '12/31/9999',
				@Lc_TypeUpdateMp_CODE		CHAR(2) = 'MP',
				@Lc_ActivityMajorCase_CODE	CHAR(4) = 'CASE',
				@Lc_ActivityMinorMpqmi_CODE	CHAR(5) = 'MPQMI';

  SELECT t.MemberMci_IDNO,
         t.MemberMciNew_IDNO,
         t.First_NAME,
         t.Last_NAME,
         t.Middle_NAME,
         t.Suffix_NAME,
         t.TypeUpdate_CODE,
         t.Source_CODE,
         t.WorkerDelegate_ID,
         t.Received_DATE,
         t.Completed_DATE,
         t.Status_CODE,
         t.TransactionEventSeqUdem_NUMB,
         t.TransactionEventSeqDemo_NUMB,
         RowCount_NUMB
      FROM ( SELECT X.MemberMci_IDNO,
	               X.MemberMciNew_IDNO,
	               X.First_NAME,
	               X.Last_NAME,
	               X.Middle_NAME,
	               X.Suffix_NAME,
	               X.TypeUpdate_CODE,
	               X.Source_CODE,
	               X.WorkerDelegate_ID,
	               X.Received_DATE,
	               X.Completed_DATE,
	               X.Status_CODE,
                   X.TransactionEventSeqUdem_NUMB,
                   X.TransactionEventSeqDemo_NUMB,
	               X.RowCount_NUMB,
	               X.ORD_ROWNUM
            FROM (  SELECT X.MemberMci_IDNO,
	                     X.MemberMciNew_IDNO,
	                     X.First_NAME,
	                     X.Last_NAME,
	                     X.Middle_NAME,
	                     X.Suffix_NAME,
	                     X.TypeUpdate_CODE,
	                     X.Source_CODE,
	                     X.WorkerDelegate_ID,
	                     X.Received_DATE,
	                     X.Completed_DATE,
	                     X.Status_CODE,
						 X.TransactionEventSeqUdem_NUMB,
						 X.TransactionEventSeqDemo_NUMB,
	                     COUNT(1) OVER() AS RowCount_NUMB,
	                     ROW_NUMBER() OVER(
	                        ORDER BY
	                           X.Received_DATE DESC,
	                           X.MemberMci_IDNO) AS ORD_ROWNUM
                  FROM ( SELECT DISTINCT U.MemberMci_IDNO,
                         		U.MemberMciNew_IDNO,
								E.First_NAME,
								E.Last_NAME,
								E.Middle_NAME,
								E.Suffix_NAME,
								U.TypeUpdate_CODE,
								U.Source_CODE,
								D.WorkerDelegate_ID,
								U.Received_DATE,
								U.Completed_DATE,
								U.Status_CODE,
								U.TransactionEventSeq_NUMB TransactionEventSeqUdem_NUMB,
								E.TransactionEventSeq_NUMB TransactionEventSeqDemo_NUMB
							FROM UDEM_Y1 U  
							 JOIN DEMO_Y1 E  
							  ON U.MemberMci_IDNO = E.MemberMci_IDNO  
							 LEFT JOIN DMNR_Y1 D  
							  ON D.MemberMci_IDNO = U.MemberMci_IDNO
							  AND D.ActivityMajor_CODE = @Lc_ActivityMajorCase_CODE
							  AND D.ActivityMinor_CODE = @Lc_ActivityMinorMpqmi_CODE
							  AND U.TypeUpdate_CODE = @Lc_TypeUpdateMp_CODE
							WHERE U.MemberMci_IDNO = ISNULL(@An_MemberMci_IDNO,U.MemberMci_IDNO)
							  AND U.TypeUpdate_CODE = ISNULL(@Ac_TypeUpdate_CODE,U.TypeUpdate_CODE)
							  AND U.Source_CODE = ISNULL(@Ac_Source_CODE,U.Source_CODE)
							  AND U.Received_DATE BETWEEN ISNULL(@Ad_ReceivedFrom_DATE,@Ld_Low_DATE) AND ISNULL(@Ad_ReceivedTo_DATE,@Ld_High_DATE)
							  AND U.Status_CODE = ISNULL(@Ac_Status_CODE,U.Status_CODE)
							  AND ISNULL(D.WorkerDelegate_ID,U.MemberMci_IDNO) = ISNULL(@Ac_WorkerDelegate_ID,ISNULL(D.WorkerDelegate_ID,U.MemberMci_IDNO))
                     )  AS X
               )  AS X
            WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB
         )  AS t
      WHERE t.ORD_ROWNUM >= @Ai_RowFrom_NUMB;


END; --END OF UDEM_RETRIEVE_S1


GO
