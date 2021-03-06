/****** Object:  StoredProcedure [dbo].[FDEM_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE 
	[dbo].[FDEM_RETRIEVE_S4] 
		( 
			 @An_Case_IDNO		NUMERIC(6,0),
			 @Ac_File_ID		CHAR(10)    ,
			 @Ac_TypeDoc_CODE	CHAR(1)		,
			 @Ai_RowFrom_NUMB	INT=1		,
			 @Ai_RowTo_NUMB		INT=10		
		)
AS

/*
 *     PROCEDURE NAME    : FDEM_RETRIEVE_S4
 *     DESCRIPTION       : RETRIEVE THE DOCUMENT DETAILS FOR A CASE,FILE AND DOCUMNET TYPE
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 25-JAN-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

      DECLARE
		 @Li_Zero_NUMB				INT		= 0 ,
		 @Li_Space_TEXT				CHAR(1)	= ' ',
         @Lc_TypeDocP_CODE			CHAR(1) = 'P',
		 @Lc_ActivityMajorCase_CODE	CHAR(4)	= 'CASE',
		 @Ld_High_DATE				DATE	= '12/31/9999';
        
          SELECT X.Case_IDNO, 
               X.File_ID, 
               X.TypeDoc_CODE, 
               X.Filed_DATE, 
               X.Petitioner_IDNO, 
               X.Respondent_IDNO,
               X.TransactionEventSeq_NUMB,
               X.DocReference_CODE, 
               X.SourceDoc_CODE, 
               X.ApprovedBy_CODE, 
               X.Petition_IDNO, 
               X.Order_IDNO,
               X.MajorIntSeq_NUMB,
               X.MinorIntSeq_NUMB,                              
               (SELECT TOP 1 j.ActivityMajor_CODE 
						FROM DMJR_Y1 j
						WHERE j.MajorIntSeq_NUMB = X.MajorIntSeq_NUMB 
						AND j.Case_IDNO = X.Case_IDNO
						AND	j.ActivityMajor_CODE <> @Lc_ActivityMajorCase_CODE) ActivityMajor_CODE,
				CASE WHEN X.TypeDoc_CODE =  @Lc_TypeDocP_CODE 
					THEN @Li_Space_TEXT
					ELSE (SELECT TOP 1 F.TypeDoc_CODE 
							 FROM FDEM_Y1 F
						WHERE F.CASE_IDNO = X.Case_IDNO 
						  AND F.File_ID = X.File_ID
						  AND F.TypeDoc_CODE =  @Lc_TypeDocP_CODE 
						  AND F.Petition_IDNO = X.Petition_IDNO 
						  AND F.Filed_DATE < X.Filed_DATE)
				 END DocOrder_CODE,
				 CASE WHEN X.TypeDoc_CODE =  @Lc_TypeDocP_CODE 
					THEN @Li_Space_TEXT
					ELSE (SELECT TOP 1 F.DocReference_CODE 
							 FROM FDEM_Y1 F
							WHERE F.CASE_IDNO = X.Case_IDNO 
							  AND F.File_ID = X.File_ID
							  AND F.TypeDoc_CODE =  @Lc_TypeDocP_CODE 
							  AND F.Petition_IDNO = X.Petition_IDNO 
							  AND F.Filed_DATE < X.Filed_DATE)
				 END DocSource_CODE,
				 (
				  SELECT TOP 1 d.File_NAME
					FROM DPRS_Y1 d
				  WHERE d.File_ID = X.File_ID 
				    AND d.DocketPerson_IDNO = X.Petitioner_IDNO 
				    AND d.EffectiveEnd_DATE = @Ld_High_DATE 
				    AND d.EndValidity_DATE = @Ld_High_DATE
				) AS Petitioner_NAME ,
				 (
					  SELECT  TOP 1 d1.File_NAME
					  FROM DPRS_Y1 d1
					  WHERE 
						  d1.File_ID = X.File_ID 
					  AND d1.DocketPerson_IDNO = X.Respondent_IDNO 
					  AND d1.EffectiveEnd_DATE = @Ld_High_DATE 
					  AND d1.EndValidity_DATE = @Ld_High_DATE
				 ) AS Respondent_NAME, 
               X.RowCount_NUMB
            FROM (
                  SELECT a.Case_IDNO, 
                     a.File_ID, 
                     a.DocReference_CODE, 
                     a.TypeDoc_CODE, 
                     a.SourceDoc_CODE, 
                     a.Filed_DATE, 
                     a.ApprovedBy_CODE ,
                     a.TransactionEventSeq_NUMB, 
                     a.Petition_IDNO,
                     a.Petitioner_IDNO, 
                     a.Respondent_IDNO, 
                     a.MajorIntSeq_NUMB,
                     a.MinorIntSeq_NUMB,
                     a.Order_IDNO,
                     COUNT(1) OVER() AS RowCount_NUMB, 
                     ROW_NUMBER() OVER(
                        ORDER BY 
                           a.Filed_DATE DESC, 
                           a.TransactionEventSeq_NUMB DESC) AS Row_NUMB
                  FROM FDEM_Y1  a
                  WHERE 
                      a.Case_IDNO = @An_Case_IDNO 
                  AND a.File_ID = @Ac_File_ID 
                  AND a.TypeDoc_CODE = ISNULL(@Ac_TypeDoc_CODE,a.TypeDoc_CODE ) 
                  AND a.Petition_IDNO <> @Li_Zero_NUMB 
                  AND a.EndValidity_DATE = @Ld_High_DATE  
               )  AS X
            WHERE X.Row_NUMB <= @Ai_RowTo_NUMB
              AND X.Row_NUMB >= @Ai_RowFrom_NUMB
		ORDER BY X.Row_NUMB;
                  
END;	--END OF FDEM_RETRIEVE_S4


GO
