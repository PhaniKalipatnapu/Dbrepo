/****** Object:  StoredProcedure [dbo].[USRT_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[USRT_RETRIEVE_S6]  
(
     @Ac_BirthCertificate_ID		CHAR(20),
     @Ac_SignedOnWorker_ID			CHAR(30),
     @Ac_Exists_INDC		 		CHAR(1)	OUTPUT
)
AS

/*
 *     PROCEDURE NAME    : USRT_RETRIEVE_S6
 *     DESCRIPTION       : Checks whether the respective Birth certificate number of the members have familial indication.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 20-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN

     

      DECLARE
         @Lc_Yes_TEXT 		CHAR(1) = 'Y', 
         @Lc_No_TEXT 		CHAR(1) = 'N', 
         @Ld_High_DATE 		DATE    = '12/31/9999',
         @Ld_Sytemdate_DATE	DATE	= DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
         
          SET @Ac_Exists_INDC = @Lc_No_TEXT;
        
      SELECT TOP 1 @Ac_Exists_INDC = @Lc_Yes_TEXT
      FROM USRT_Y1 U
      		JOIN 
      		MPAT_Y1 M
      			ON (U.MemberMci_IDNO = M.MemberMci_IDNO)	
      WHERE 
         M.BirthCertificate_ID = @Ac_BirthCertificate_ID AND 
         U.EndValidity_DATE = @Ld_High_DATE AND 
         U.Familial_INDC = @Lc_Yes_TEXT AND 
         U.Worker_ID = @Ac_SignedOnWorker_ID AND 
         U.End_DATE > @Ld_Sytemdate_DATE;
                  
END;-- End Of USRT_RETRIEVE_S6


GO
