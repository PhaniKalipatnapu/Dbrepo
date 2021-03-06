/****** Object:  StoredProcedure [dbo].[OTHP_RETRIEVE_S82]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_RETRIEVE_S82] (
 @An_OtherParty_IDNO     NUMERIC(9, 0),
 @Ac_TypeActivity_CODE   CHAR(1),
 @Ac_ActivityMinor_CODE  CHAR(5),   
 @As_OtherParty_NAME     VARCHAR(60) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : OTHP_RETRIEVE_S82
  *     DESCRIPTION       : Retrieve the Other Party Name and Other Party number for an Other Party number, Other Party Type is Courts or Labs/Genetic Test or Office.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 07-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @As_OtherParty_NAME = NULL;

  DECLARE @Lc_SchLocTypeLab_CODE   CHAR(1) = 'L',
  		  @Lc_SchLocTypeCourt_CODE CHAR(1) = 'C',
          @Lc_AddrStateDe_TEXT     CHAR(2) = 'DE',
          @Lc_TypeActivityC_CODE   CHAR(4) = 'C',
          @Lc_TypeActivityA_CODE   CHAR(4) = 'A',
          @Lc_TypeActivityG_CODE   CHAR(4) = 'G',
          @Lc_TypeActivityH_CODE   CHAR(4) = 'H',
          @Ld_High_DATE            DATE = '12/31/9999';

  SELECT @As_OtherParty_NAME = Otherparty_NAME
  FROM (
	 SELECT Office_NAME AS Otherparty_NAME
	  FROM OFIC_Y1 O
	       JOIN
	       OTHP_Y1 O1
	       ON (O.OtherParty_IDNO=O1.OtherParty_IDNO)
	       JOIN
	       AMNR_Y1 A    
           ON  O1.TypeOthp_CODE IN (A.TypeLocation1_CODE,A.TypeLocation2_CODE)            
	  WHERE O.OtherParty_IDNO = @An_OtherParty_IDNO
	    AND A.ActivityMinor_CODE =ISNULL(@Ac_ActivityMinor_CODE,A.ActivityMinor_CODE)     
	    AND (@Ac_TypeActivity_CODE IN (@Lc_TypeActivityC_CODE, @Lc_TypeActivityA_CODE)
	          OR @Ac_TypeActivity_CODE IS NULL)
		AND O.EndValidity_DATE = @Ld_High_DATE     
	  UNION         
	  SELECT H.OtherParty_NAME 
		FROM OTHP_Y1 H
		     JOIN
		     AMNR_Y1 A
		     ON  H.TypeOthp_CODE IN (A.TypeLocation1_CODE,A.TypeLocation2_CODE)            
	   WHERE H.OtherParty_IDNO = @An_OtherParty_IDNO
	     AND A.ActivityMinor_CODE =ISNULL(@Ac_ActivityMinor_CODE,A.ActivityMinor_CODE)  
		 AND (@Ac_TypeActivity_CODE IN (@Lc_TypeActivityG_CODE, @Lc_TypeActivityH_CODE)							
		      OR @Ac_TypeActivity_CODE IS NULL)
		 AND ( H.TypeOthp_CODE = @Lc_SchLocTypeLab_CODE
			   OR H.TypeOthp_CODE = @Lc_SchLocTypeCourt_CODE)
		 AND H.EndValidity_DATE = @Ld_High_DATE )AS A ;
     
 END; --END OF OTHP_RETRIEVE_S82
 
GO
