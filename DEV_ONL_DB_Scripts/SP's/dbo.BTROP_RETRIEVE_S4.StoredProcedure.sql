/****** Object:  StoredProcedure [dbo].[BTROP_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE   PROCEDURE [dbo].[BTROP_RETRIEVE_S4] (
      @Ac_Template_NAME            CHAR   (30)  ,
      @Ac_SignedOnWorker_ID        CHAR   (30)  ,
      @Ac_Worker_ID                CHAR   (30)  , 
      @As_Privilege_TEXT           VARCHAR(500) , 
      @Ad_Create_DATE              DATE         ,
      @As_PrivilegeRole_TEXT       VARCHAR(8000) 
   )
   AS
   /*      
  *     PROCEDURE NAME    : BTROP_RETRIEVE_S4      
  *     DESCRIPTION       : Used to display the list of available report profiles that can be viewed
                            by the logged on user	     
  *     DEVELOPED BY      : IMP Team     
  *     DEVELOPED ON      : 12-AUG-2011      
  *     MODIFIED BY       :       
  *     MODIFIED ON       :       
  *     VERSION NO        : 1   
  
 */ 
 BEGIN     
   DECLARE 
      @Lc_All_CODE          CHAR(3)  = 'ALL',     
      @Lc_Private_CODE	    CHAR (7) = 'PRIVATE', 
      @Lc_Role_CODE         CHAR(1)  = 'R',
      @Li_Zero_NUMB			SMALLINT = 0,
      @Lc_Percentage_TEXT   CHAR(1)	 = '%' ;
   
               
                 SELECT a.Report_IDNO,
                        a.Template_NAME,
                        a.OptionValue_TEXT ,
                        a.OptionXml_TEXT,
                        a.Worker_ID ,
                        a.Privilege_TEXT,
                        a.Create_DATE,
                        a.Comments_TEXT
                   FROM BTROP_Y1 a
                  WHERE ( 	@Ac_Template_NAME IS NULL OR a.Template_NAME LIKE @Lc_Percentage_TEXT + RTRIM(@Ac_Template_NAME) + @Lc_Percentage_TEXT)
                    AND (	@Ac_Worker_ID IS NULL 
                    		OR a.Worker_ID LIKE @Lc_Percentage_TEXT + RTRIM(@Ac_Worker_ID) + @Lc_Percentage_TEXT)
                    AND (	@Ad_Create_DATE IS NULL 
                    		OR a.Create_DATE = @Ad_Create_DATE)
                    AND ( (		@As_Privilege_TEXT = @Lc_private_CODE
							AND a.Privilege_TEXT = @Lc_private_CODE
							AND a.Worker_ID = @Ac_SignedOnWorker_ID
							)
						  OR(	    @As_Privilege_TEXT = @Lc_Role_CODE
							AND (	CHARINDEX (@As_PrivilegeRole_TEXT,a.Privilege_TEXT ) > @Li_Zero_NUMB
									 OR CHARINDEX (a.Privilege_TEXT,@As_PrivilegeRole_TEXT) > @Li_Zero_NUMB
								)
                             )
                          OR (	 @As_Privilege_TEXT = @Lc_All_CODE
							AND (   (    a.Privilege_TEXT = @Lc_private_CODE
                                     AND a.Worker_ID = @Ac_SignedOnWorker_ID
                                    )
                                 OR CHARINDEX (a.Privilege_TEXT, @As_PrivilegeRole_TEXT) > @Li_Zero_NUMB
                                 OR CHARINDEX (@As_PrivilegeRole_TEXT, a.Privilege_TEXT) > @Li_Zero_NUMB
                                )
                             )
                          );
   END;  --END OF BTROP_RETRIEVE_S4

GO
