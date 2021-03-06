/****** Object:  StoredProcedure [dbo].[MHIS_RETRIEVE_S46]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MHIS_RETRIEVE_S46] (                         	
     @An_Case_IDNO				NUMERIC(6,0),
     @An_MemberMci_IDNO			NUMERIC(10,0),
     @An_SupportYearMonth_NUMB	NUMERIC(6,0),  
     @Ac_TypeWelfare_CODE		CHAR(1)  	OUTPUT
)
AS                                      	 

/*
 *     PROCEDURE NAME    : MHIS_RETRIEVE_S46
 *     DESCRIPTION       : This procedure retruns the type of welfare from MHIS_Y1 for Case Member. 
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 19-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
		DECLARE @Li_Hundred_NUMB	SMALLINT = 100,
				@Li_One_NUMB		SMALLINT = 1,
				@Li_MinusOne_NUMB	SMALLINT = -1,
				@Li_Year_NUMB		INT,
				@Li_Month_NUMB		INT,
				@Ld_LastDay_DATE	DATE;
		
		SET @Li_Year_NUMB	 = @An_SupportYearMonth_NUMB / @Li_Hundred_NUMB;
		SET @Li_Month_NUMB	 = @An_SupportYearMonth_NUMB -  (@Li_Year_NUMB * @Li_Hundred_NUMB) ; 
		SET @Ld_LastDay_DATE = CONVERT(VARCHAR,@Li_Month_NUMB ) + '/01/' + CONVERT(VARCHAR,@Li_Year_NUMB);
		SET @Ld_LastDay_DATE = DATEADD(D,@Li_MinusOne_NUMB,DATEADD(M,@Li_One_NUMB,@Ld_LastDay_DATE));
		SET @Ac_TypeWelfare_CODE = NULL;
		      
      SELECT @Ac_TypeWelfare_CODE = a.TypeWelfare_CODE
        FROM MHIS_Y1 a
       WHERE a.Case_IDNO = @An_Case_IDNO 
         AND a.MemberMci_IDNO = @An_MemberMci_IDNO 
         AND @Ld_LastDay_DATE BETWEEN a.Start_DATE AND a.End_DATE;
         
END;--End of  MHIS_RETRIEVE_S46


GO
