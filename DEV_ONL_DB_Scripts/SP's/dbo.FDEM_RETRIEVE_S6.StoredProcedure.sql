/****** Object:  StoredProcedure [dbo].[FDEM_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE 
	[dbo].[FDEM_RETRIEVE_S6]  
		(
			 @An_Case_IDNO					NUMERIC(6,0),
			 @Ac_File_ID					CHAR(10)	,
			 @Ac_TypeDoc_CODE				CHAR(1)		,
			 @Ad_Filed_DATE					DATE		,
			 @An_Petitioner_IDNO			NUMERIC(10,0),
			 @An_Respondent_IDNO			NUMERIC(10,0),
			 @An_TransactionEventSeq_NUMB	NUMERIC(19,0),
			 @Ac_DocReference_CODE			CHAR(4)		,
			 @Ac_Exists_INDC				CHAR(1)		OUTPUT
		)
AS

/*
 *     PROCEDURE NAME    : FDEM_RETRIEVE_S6
 *     DESCRIPTION       : Check the existance to check Concurrency
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 25-JAN-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

       DECLARE
         @Lc_Yes_INDC		CHAR(1)	=	'Y',
         @Lc_No_INDC		CHAR(1) =	'N',
         @Ld_High_DATE		DATE	= '12/31/9999';
         
         SET 
			@Ac_Exists_INDC = @Lc_No_INDC ;
        
		SELECT @Ac_Exists_INDC = @Lc_Yes_INDC
		 FROM FDEM_Y1 F
		WHERE 
			F.Case_IDNO = @An_Case_IDNO 
        AND F.File_ID = @Ac_File_ID 
        AND F.TypeDoc_CODE = @Ac_TypeDoc_CODE  
        AND F.Petitioner_IDNO =@An_Petitioner_IDNO	
        AND F.Respondent_IDNO=@An_Respondent_IDNO	
        AND F.DocReference_CODE=@Ac_DocReference_CODE	
        AND F.Filed_DATE = @Ad_Filed_DATE 
        AND F.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB 
        AND F.EndValidity_DATE = @Ld_High_DATE;
                  
END;	--END OF FDEM_RETRIEVE_S6


GO
