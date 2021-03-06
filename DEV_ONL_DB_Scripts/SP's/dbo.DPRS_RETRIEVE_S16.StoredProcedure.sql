/****** Object:  StoredProcedure [dbo].[DPRS_RETRIEVE_S16]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DPRS_RETRIEVE_S16] (     
     @Ac_File_ID						CHAR(10),
     @An_TransactionEventSeqOld_NUMB	NUMERIC(19,0),
     @Ac_Exists_INDC					CHAR(1)	OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : DPRS_RETRIEVE_S16
 *     DESCRIPTION       : Checking given File_ID with TransactionEventSeq_NUMB Exists in Docket Persons table.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-MAR-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN

	DECLARE @Ld_High_DATE 	DATE	= '12/31/9999',
			@Lc_No_TEXT		CHAR(1)	= 'N',
		  	@Lc_Yes_TEXT	CHAR(1)	= 'Y';
		  	
	SET @Ac_Exists_INDC = @Lc_No_TEXT;
        
	SELECT @Ac_Exists_INDC = @Lc_Yes_TEXT
	FROM DPRS_Y1 D
	WHERE D.File_ID = @Ac_File_ID 
	AND D.TransactionEventSeq_NUMB = @An_TransactionEventSeqOld_NUMB 
	AND D.EndValidity_DATE = @Ld_High_DATE;

                  
END; --END OF DPRS_RETRIEVE_S16


GO
