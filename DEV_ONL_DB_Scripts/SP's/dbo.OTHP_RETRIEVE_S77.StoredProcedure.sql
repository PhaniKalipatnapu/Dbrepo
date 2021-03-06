/****** Object:  StoredProcedure [dbo].[OTHP_RETRIEVE_S77]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OTHP_RETRIEVE_S77] (  
 @An_County_IDNO        NUMERIC(3, 0),  
 @As_OtherParty_NAME    VARCHAR(60),  
 @Ac_State_ADDR         CHAR(2),
 @Ac_ActivityMinor_CODE CHAR(5),   
 @Ac_TypeActivity_CODE  CHAR(1),  
 @Ai_RowFrom_NUMB       INT = 1,  
 @Ai_RowTo_NUMB         INT = 10  
 )  
AS  
 /*    
  *     PROCEDURE NAME    : OTHP_RETRIEVE_S77    
  *     DESCRIPTION       : Retrieve Other Party Idno and Office Code, Name, and Address for an Other Party Name and County Code, Other Party Type, Other Party Reference Idno, and State Address.    
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 06-SEP-2011       
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
 */  
 BEGIN  
  DECLARE @Ld_High_DATE                DATE = '12/31/9999',  
          @Lc_ActivityTypeHearing_CODE CHAR(1) = 'H',  
          @Lc_SchLocTypeCourt_CODE     CHAR(1) = 'C',  
          @Lc_SchLocTypeOffice_CODE    CHAR(1) = 'O';
          
    WITH TypeLoc_CTE   
      AS (SELECT A.TypeLocation1_CODE ,
             A.TypeLocation2_CODE   
           FROM AMNR_Y1 A    
           WHERE A.ActivityMinor_CODE= @Ac_ActivityMinor_CODE  
            AND A.TypeActivity_CODE=@Ac_TypeActivity_CODE)           

    SELECT T.OtherParty_IDNO,  
         T.OtherParty_NAME,  
         T.City_ADDR,  
         T.State_ADDR,
         TypeOthp_CODE, 
         RowCount_NUMB  
    FROM (SELECT M.OtherParty_IDNO,  
                 M.OtherParty_NAME,  
                 M.City_ADDR,  
                 M.State_ADDR,  
                 M.TypeOthp_CODE,  
                 M.RowCount_NUMB,  
                 M.ORD_ROWNUM  
            FROM (SELECT N.OtherParty_IDNO,  
                         N.OtherParty_NAME,  
                         N.City_ADDR,  
                         N.State_ADDR,  
                         N.TypeOthp_CODE,  
                         COUNT(1) OVER() AS RowCount_NUMB,  
                         N.ORD_ROWNUM  
                    FROM (SELECT K.OtherParty_IDNO,  
                                 K.OtherParty_NAME,  
                                 K.City_ADDR,  
                                 K.State_ADDR,  
                                 K.TypeOthp_CODE,  
                                 ROW_NUMBER() OVER( ORDER BY K.OtherParty_NAME, K.OtherParty_IDNO) AS ORD_ROWNUM  
                            FROM (SELECT B.OtherParty_IDNO,  
                                         B.OtherParty_NAME,  
                                         B.City_ADDR,  
                                         B.State_ADDR,  
                                         B.TypeOthp_CODE
                                    FROM OFIC_Y1 A  
                                         JOIN OTHP_Y1 B  
                                          ON A.OtherParty_IDNO = B.OtherParty_IDNO
                                         JOIN TypeLoc_CTE C
                                         ON @Lc_SchLocTypeOffice_CODE IN (C.TypeLocation1_CODE,C.TypeLocation2_CODE )      
                                   WHERE B.OtherParty_NAME >= ISNULL(@As_OtherParty_NAME, b.OtherParty_NAME)  
                                     AND B.EndValidity_DATE = @Ld_High_DATE  
                                     AND B.County_IDNO = ISNULL(@An_County_IDNO, B.County_IDNO)  
                                  UNION  
                                  SELECT B.OtherParty_IDNO,  
                                         CASE  
                                          WHEN @Ac_TypeActivity_CODE = @Lc_ActivityTypeHearing_CODE  
                                                OR B.TypeOthp_CODE = @Lc_SchLocTypeCourt_CODE  
                                           THEN ISNULL(ISNULL(CAST(B.ReferenceOthp_IDNO AS VARCHAR), '') + CASE  
                                                                                                     WHEN B.ReferenceOthp_IDNO <> 0  
                                                                                                      THEN ' - '  
                                         END + ISNULL(B.OtherParty_NAME, '') ,B.OtherParty_NAME)
                                          ELSE B.OtherParty_NAME  
                                         END AS OtherParty_NAME,  
                                         B.City_ADDR,  
                                         B.State_ADDR,  
                                         B.TypeOthp_CODE 
                                    FROM OTHP_Y1 B
                                         JOIN TypeLoc_CTE C
                                         ON B.TypeOthp_CODE IN (C.TypeLocation1_CODE,C.TypeLocation2_CODE )   
                                   WHERE  B.TypeOthp_CODE != @Lc_SchLocTypeOffice_CODE  
                                     AND B.State_ADDR = ISNULL(@Ac_State_ADDR, B.State_ADDR)  
                                     AND B.OtherParty_NAME >= ISNULL(@As_OtherParty_NAME, B.OtherParty_NAME)  
                                     AND B.EndValidity_DATE = @Ld_High_DATE  
                                     AND B.County_IDNO = ISNULL(@An_County_IDNO, B.County_IDNO)  
                                    )AS K) AS N) AS M  
           WHERE M.ORD_ROWNUM <= @Ai_RowTo_NUMB) AS T  
   WHERE ORD_ROWNUM >= @Ai_RowFrom_NUMB  
   ORDER BY ORD_ROWNUM;  
 END; --END OF OTHP_RETRIEVE_S77  
  

GO
