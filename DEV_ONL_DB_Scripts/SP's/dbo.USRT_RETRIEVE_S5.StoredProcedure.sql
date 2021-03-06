/****** Object:  StoredProcedure [dbo].[USRT_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[USRT_RETRIEVE_S5]  
(
     @An_Case_IDNO		 		NUMERIC(6,0),
     @An_MemberMci_IDNO			NUMERIC(10,0),
     @Ac_SignedOnWorker_ID		CHAR(30),
     @Ac_Exists_INDC			CHAR(1)	 OUTPUT
)
AS

/*
 *     PROCEDURE NAME    : USRT_RETRIEVE_S5
 *     DESCRIPTION       : Checks whether the respective case has the Familial indication.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN

      SET @Ac_Exists_INDC = NULL;

      DECLARE
         @Lc_Yes_INDC 			CHAR(1) = 'Y', 
         @Ld_High_DATE 			DATE = '12/31/9999',
         @Ld_SystemDate_DATE	DATE	= DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
        
        SELECT TOP 1 @Ac_Exists_INDC = @Lc_Yes_INDC 
      	FROM USRT_Y1  U
      WHERE 
         U.Case_IDNO = ISNULL(@An_Case_IDNO,U.Case_IDNO) AND 
         U.MemberMci_IDNO = ISNULL(@An_MemberMci_IDNO,U.MemberMci_IDNO) AND
         U.EndValidity_DATE = @Ld_High_DATE AND 
         U.Familial_INDC = @Lc_Yes_INDC AND 
         U.Worker_ID = @Ac_SignedOnWorker_ID AND 
         U.End_DATE > @Ld_SystemDate_DATE;

                  
END; -- End Of USRT_RETRIEVE_S5


GO
