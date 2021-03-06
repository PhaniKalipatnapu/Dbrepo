/****** Object:  StoredProcedure [dbo].[USRT_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USRT_RETRIEVE_S2]  
(
     @An_Case_IDNO			NUMERIC(6,0) = NULL,
     @An_MemberMci_IDNO		NUMERIC(10,0) = NULL,
     @Ac_Exists_INDC		CHAR(1)	 		OUTPUT
)
AS

/*
 *     PROCEDURE NAME    : USRT_RETRIEVE_S2
 *     DESCRIPTION       : Checks whether the respective Case or Case members have high profile indication.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN

      SET @Ac_Exists_INDC = NULL;

      DECLARE
         @Lc_YES_INDC 	CHAR(1) = 'Y', 
         @Ld_High_DATE 	DATE 	= '12/31/9999',
         @Ld_SystemDate_DATE	DATE	=DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() ;
        
        SELECT TOP 1 @Ac_Exists_INDC = @Lc_YES_INDC
      FROM USRT_Y1 U 
      WHERE 
         U.Case_IDNO =  ISNULL(@An_Case_IDNO,U.Case_IDNO) AND
         U.MemberMci_IDNO = ISNULL(@An_MemberMci_IDNO,U.MemberMci_IDNO) AND
         U.EndValidity_DATE = @Ld_High_DATE AND 
         U.HighProfile_INDC = @Lc_YES_INDC AND 
         U.End_DATE > @Ld_SystemDate_DATE;

                  
END; -- End Of USRT_RETRIEVE_S2


GO
