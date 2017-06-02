<?php

namespace PIA\appBundle\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * TestLinks
 */
class TestLinks
{
    /**
     * @var integer
     */
    private $id;

    /**
     * @var string
     */
    private $link;

    /**
     * @var integer
     */
    private $lev;


    /**
     * Get id
     *
     * @return integer 
     */
    public function getId()
    {
        return $this->id;
    }

    /**
     * Set link
     *
     * @param string $link
     * @return TestLinks
     */
    public function setLink($link)
    {
        $this->link = $link;

        return $this;
    }

    /**
     * Get link
     *
     * @return string 
     */
    public function getLink()
    {
        return $this->link;
    }

    /**
     * Set lev
     *
     * @param integer $lev
     * @return TestLinks
     */
    public function setLev($lev)
    {
        $this->lev = $lev;

        return $this;
    }

    /**
     * Get lev
     *
     * @return integer 
     */
    public function getLev()
    {
        return $this->lev;
    }
}
