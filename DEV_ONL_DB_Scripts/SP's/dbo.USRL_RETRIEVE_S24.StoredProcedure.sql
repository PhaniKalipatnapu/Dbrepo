/****** Object:  StoredProcedure [dbo].[USRL_RETRIEVE_S24]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[USRL_RETRIEVE_S24]  
(
	 @Ac_SignedOnWorker_ID		CHAR(30),
     @An_SignedOnCounty_IDNO	NUMERIC(3,0),     
     @Ac_Exists_INDC			CHAR(1)	 OUTPUT
)
AS

/*
 *     PROCEDURE NAME    : USRL_RETRIEVE_S24
 *     DESCRIPTION       : Checks Whether the worker logged in has high profile role.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

     

      DECLARE
         @Lc_Yes_TEXT 				CHAR(1)  = 'Y', 
         @Lc_No_TEXT 				CHAR(1)  = 'N', 
         @Ld_High_DATE 				DATE	 = '12/31/9999', 
         @Lc_RoleHighProfile_CODE 	CHAR(10) = 'RS001',
         @Ld_SystemDate_DATE		DATE	 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
         
          SET @Ac_Exists_INDC = @Lc_No_TEXT;
        
    SELECT @Ac_Exists_INDC = @Lc_Yes_TEXT
      FROM USRL_Y1  U
      WHERE 
         U.Worker_ID = @Ac_SignedOnWorker_ID AND 
         U.Office_IDNO = @An_SignedOnCounty_IDNO AND 
         U.Role_ID = @Lc_RoleHighProfile_CODE AND 
         U.EndValidity_DATE = @Ld_High_DATE AND 
         U.Expire_DATE > @Ld_SystemDate_DATE AND
         U.Effective_DATE <= @Ld_SystemDate_DATE;  
                  
END; -- End Of USRL_RETRIEVE_S24


GO
