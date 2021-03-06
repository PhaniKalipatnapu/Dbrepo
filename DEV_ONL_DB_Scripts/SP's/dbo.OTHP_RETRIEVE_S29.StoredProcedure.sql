/****** Object:  StoredProcedure [dbo].[OTHP_RETRIEVE_S29]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_RETRIEVE_S29] (
 @An_OtherParty_IDNO      NUMERIC(9, 0),
 @Ac_TypeOthp_CODE        CHAR(1),
 @Ac_Exists_INDC          CHAR(1) OUTPUT
 )
AS
 /*                                                                                                                       
  *     PROCEDURE NAME    : OTHP_RETRIEVE_S29                                                                              
  *     DESCRIPTION       : Retrieve the Row count for a given other party number and other party type.                                                                                              
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 23-SEP-2011                                                                                   
  *     MODIFIED BY       :                                                                                               
  *     MODIFIED ON       :                                                                                               
  *     VERSION NO        : 1                                                                                             
 */
 BEGIN
    DECLARE
        @Lc_Yes_TEXT      CHAR(1) ='Y',
        @Lc_No_TEXT      CHAR(1) ='N';
        
  SET @Ac_Exists_INDC = @Lc_No_TEXT;

  SELECT @Ac_Exists_INDC =  @Lc_Yes_TEXT
    FROM OTHP_Y1 O
   WHERE O.OtherParty_IDNO = @An_OtherParty_IDNO
     AND (@Ac_TypeOthp_CODE IS NULL
           OR (@Ac_TypeOthp_CODE IS NOT NULL
               AND O.TypeOthp_CODE = @Ac_TypeOthp_CODE));
 END; --END OF OTHP_RETRIEVE_S29                                                                                           



GO
