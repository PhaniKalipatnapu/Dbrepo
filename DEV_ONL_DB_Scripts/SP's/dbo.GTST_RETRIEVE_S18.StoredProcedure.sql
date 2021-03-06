/****** Object:  StoredProcedure [dbo].[GTST_RETRIEVE_S18]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[GTST_RETRIEVE_S18]
(  

     @An_Case_IDNO                            NUMERIC(6)           ,
     @An_MemberMci_IDNO                       NUMERIC(10)           ,
     @Ac_Exists_INDC                          CHAR(1)    OUTPUT
)
AS

/*
*      PROCEDURE NAME    : GTST_RETRIEVE_S18
 *     DESCRIPTION       : This sp is used find whether the particular case id or member id exists in the GTST_Y1 table.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN

      DECLARE
         @Lc_Yes_TEXT      CHAR(1) = 'Y',  
          @Lc_No_TEXT      CHAR(1) = 'N',
         @Ld_High_DATE     DATE    = '12/31/9999';
         
         SET @Ac_Exists_INDC = @Lc_No_TEXT;  
         
      SELECT TOP 1 @Ac_Exists_INDC  = @Lc_Yes_TEXT
      FROM   GTST_Y1 a
      WHERE @An_MemberMci_IDNO = a.MemberMci_IDNO 
      AND   @An_Case_IDNO      = a.Case_IDNO 
      AND   a.EndValidity_DATE = @Ld_High_DATE;

                  
END -- END of GTST_RETRIEVE_S18


GO
