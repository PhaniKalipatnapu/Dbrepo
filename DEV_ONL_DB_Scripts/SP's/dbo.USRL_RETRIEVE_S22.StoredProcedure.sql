/****** Object:  StoredProcedure [dbo].[USRL_RETRIEVE_S22]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USRL_RETRIEVE_S22]  (

     @Ac_SignedOnWorker_ID	 CHAR(30),
     @Ac_Exists_INDC         CHAR(1)  OUTPUT
     )
AS

/*
 *     PROCEDURE NAME    : USRL_RETRIEVE_S22
 *     DESCRIPTION       : check whether the worker is  exists or not.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN     
	    
	    SET @Ac_Exists_INDC = 'N'; 
	    
      DECLARE
         @Ld_High_DATE               DATE = '12/31/9999', 
         @Ld_Current_DATE			 DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
         @Lc_RefmIdTableSubRole_ID   CHAR(4) = 'ROLE', 
         @Lc_RefmIdTableUrct_ID      CHAR(4) = 'URCT',
         @Lc_Yes_INDC                CHAR(1) = 'Y';  
       
        
        SELECT  @Ac_Exists_INDC = @Lc_Yes_INDC
         FROM USRL_Y1 U
         WHERE U.Worker_ID = @Ac_SignedOnWorker_ID 
          AND  U.Role_ID IN 
           (
             SELECT R.Value_CODE
              FROM REFM_Y1 R
              WHERE R.Table_ID = @Lc_RefmIdTableUrct_ID 
               AND  R.TableSub_ID = @Lc_RefmIdTableSubRole_ID
           ) 
         AND U.EndValidity_DATE = @Ld_High_DATE
         AND @Ld_Current_DATE BETWEEN U.Effective_DATE AND U.Expire_DATE;

                  
END; --END OF USRL_RETRIEVE_S22


GO
