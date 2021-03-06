/****** Object:  StoredProcedure [dbo].[USRT_RETRIEVE_S7]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USRT_RETRIEVE_S7]  
(
     @Ac_File_ID		 		CHAR(10),
     @Ac_SignedOnWorker_ID		CHAR(30),
     @Ac_Exists_INDC		 	CHAR(1)	 OUTPUT
)
AS

/*
 *     PROCEDURE NAME    : USRT_RETRIEVE_S7
 *     DESCRIPTION       : Checks whether the respective case has familial indication using the File Id.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

      

      DECLARE
         @Lc_Yes_TEXT 		CHAR(1) = 'Y', 
         @Lc_No_TEXT 		CHAR(1) = 'N', 
         @Ld_High_DATE 		DATE 	= '12/31/9999',
         @Ld_SystemDate_DATE	DATE	= DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
         
         SET @Ac_Exists_INDC = @Lc_No_TEXT;
        
      SELECT TOP 1 @Ac_Exists_INDC = @Lc_Yes_TEXT
      FROM USRT_Y1 U
      		JOIN
      	   CASE_Y1  C
      	  ON (U.Case_IDNO = C.Case_IDNO ) 
      WHERE 
         C.File_ID = @Ac_File_ID AND 
         U.EndValidity_DATE = @Ld_High_DATE AND 
         U.Familial_INDC = @Lc_Yes_TEXT AND 
         U.Worker_ID = @Ac_SignedOnWorker_ID AND 
         U.End_DATE > @Ld_SystemDate_DATE;

                  
END; -- End Of USRT_RETRIEVE_S7


GO
